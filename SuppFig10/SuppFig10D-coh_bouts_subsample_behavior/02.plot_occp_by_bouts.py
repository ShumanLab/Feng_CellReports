# %% imports and definitions
import os
import re
import warnings

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import statsmodels.api as sm
import xarray as xr
from statsmodels.formula.api import ols
from statsmodels.stats.anova import AnovaRM
from tqdm.auto import tqdm

from routine.io import load_data
from routine.place_cells import est_by_track_trial
from routine.plotting import line_dist
from routine.utilities import df_set_metadata

IN_DPATH = "./intermediate/processed"
BOUT_DPATH = "./data/coh_bouts"
PARAM_SMP_SPACE = {1: np.linspace(0, 4.27, 30), 2: np.linspace(4.29, 8.9, 30)}
PARAM_SMP_RATE = 2.5e4
PARAM_DS = 10
PARAM_SKIP_EXISTING = False
OUT_PATH = "./intermediate/bout_occp"
FIG_PATH = "./figs/bout_occp"
os.makedirs(OUT_PATH, exist_ok=True)
os.makedirs(FIG_PATH, exist_ok=True)

# %% extract bout occupancy
bout_files = pd.DataFrame(
    [
        re.search(
            r"(?P<animal>TS[0-9]+-[0-9]+)_(?P<match>.*)align_ind_run", fn
        ).groupdict()
        | {"filename": os.path.join(BOUT_DPATH, fn)}
        for fn in os.listdir(BOUT_DPATH)
    ]
).set_index("animal")
occp_df = []
for anm in tqdm(os.listdir(IN_DPATH)):
    ds = load_data(os.path.join(IN_DPATH, anm))
    pos = list(ds.values())[0].coords["pos"]
    try:
        anm_bouts = bout_files.loc[anm]
    except KeyError:
        continue
    ds_idx = np.zeros_like(pos, dtype=bool)
    ds_idx[np.arange(0, pos.sizes["smp_idx"], PARAM_DS)] = True
    sub_idx = np.logical_and.reduce(
        (pos.coords["isRunning"], pos.coords["track"] > 0, pos.coords["trial"] > 0)
    )
    sub_idx = np.logical_and(sub_idx, ds_idx)
    occp_all = est_by_track_trial(
        pos.sel(smp_idx=sub_idx).coords.to_dataset(),
        var_name="pos",
        bw_method=None,
        smp_space=PARAM_SMP_SPACE,
        method="hist",
    ).rename(columns={"pos": "occp"})
    occp_all["occp"] = occp_all["occp"] / (PARAM_SMP_RATE / PARAM_DS)
    occp_all = occp_all[occp_all["trial"] == -1].drop(columns="trial")
    occp_all = df_set_metadata(occp_all, {"match": "all", "animal": anm})
    occp_df.append(occp_all)
    for ma, cur_bout in anm_bouts.set_index("match").iterrows():
        bt = (
            pd.read_csv(cur_bout["filename"], header=None).values.squeeze().astype(bool)
        )
        bt_lab = np.repeat(bt, PARAM_SMP_RATE)
        diff = pos.sizes["smp_idx"] - len(bt_lab)
        if diff / PARAM_SMP_RATE > 5:
            warnings.warn(
                "{:.2f} seconds of data missing from {} bouts label for animal {}".format(
                    diff / PARAM_SMP_RATE, ma, anm
                )
            )
        bt_lab = xr.DataArray(
            np.concatenate([bt_lab, np.zeros(diff, dtype=bool)]),
            dims=["smp_idx"],
            coords={"smp_idx": pos.coords["smp_idx"]},
        )
        pos_sub = pos.sel(smp_idx=np.logical_and(bt_lab, sub_idx))
        if not pos_sub.sizes["smp_idx"] > 0:
            continue
        occp = est_by_track_trial(
            pos_sub.coords.to_dataset(),
            var_name="pos",
            bw_method=None,
            smp_space=PARAM_SMP_SPACE,
            method="hist",
        ).rename(columns={"pos": "occp"})
        occp["occp"] = occp["occp"] / (PARAM_SMP_RATE / PARAM_DS)
        occp = occp[occp["trial"] == -1].drop(columns="trial")
        occp = df_set_metadata(occp, {"match": ma, "animal": anm})
        occp_df.append(occp)
occp_df = pd.concat(occp_df, ignore_index=True)
occp_df.to_feather(os.path.join(OUT_PATH, "bout_occp.feat"))


# %% aggregate data and run stats
def norm_match(dat):
    dat = dat.set_index("smp_space")
    dat_all = dat[dat["match"] == "all"]["occp"]
    res_df = []
    for ma, ma_df in dat.groupby("match"):
        ma_df["occp_norm"] = ma_df["occp"] / dat_all
        res_df.append(ma_df)
    return pd.concat(res_df).reset_index()


occp = pd.read_feather(os.path.join(OUT_PATH, "bout_occp.feat"))
occp = occp[occp["track"] == 1].drop(columns="track")
occp = occp.groupby("animal").apply(norm_match).reset_index(drop=True)
occp["occp_norm"] = occp.groupby(["animal", "match"])["occp"].transform(
    lambda oc: oc / oc.sum()
)
occp = occp[occp["match"] != "all"].copy()
occp["smp_space"] = occp["smp_space"] * 2 / 4.27
for ma, ma_df in occp.groupby("match"):
    for incl, dat in {
        "full": ma_df,
        "exclude_0": ma_df[ma_df["smp_space"] > 0],
    }.items():
        model = ols("occp_norm ~ C(smp_space) + animal", data=dat).fit()
        anv_tb = sm.stats.anova_lm(model, typ=2)
        anv_rm = AnovaRM(
            data=dat, depvar="occp_norm", subject="animal", within=["smp_space"]
        ).fit()
        print("{} - {} :".format(incl, ma))
        print(anv_rm)

# %% plotting
tab10 = plt.get_cmap("tab10").colors
cmap = {"DGCA1": tab10[0], "M2M3": tab10[2], "M2MO": tab10[1]}
# line style
g = sns.FacetGrid(
    occp,
    col="animal",
    col_wrap=4,
    aspect=2,
    height=2,
    legend_out=True,
    sharey=False,
    sharex=False,
)
g.map_dataframe(
    line_dist,
    x="smp_space",
    y="occp_norm",
    hue="match",
    palette=cmap,
    area_alpha=0.15,
)
g.add_legend()
g.figure.savefig(
    os.path.join(FIG_PATH, "by_animal-line.svg"), dpi=500, bbox_inches="tight"
)
# bar style
g = sns.FacetGrid(
    occp,
    col="animal",
    col_wrap=4,
    aspect=2.5,
    height=2.5,
    legend_out=True,
    sharey=False,
)
g.map_dataframe(
    sns.barplot,
    x="smp_space",
    y="occp_norm",
    hue="match",
    palette=cmap,
    dodge=True,
    native_scale=True,
)
g.add_legend()
g.figure.savefig(
    os.path.join(FIG_PATH, "by_animal-bar.svg"), dpi=500, bbox_inches="tight"
)
# agg
fig, ax = plt.subplots()
ax = sns.lineplot(
    occp,
    x="smp_space",
    y="occp_norm",
    hue="match",
    palette=cmap,
    errorbar="se",
    ax=ax,
)
fig.savefig(os.path.join(FIG_PATH, "agg-line.svg"), dpi=500, bbox_inches="tight")
# agg separate
g = sns.FacetGrid(
    occp,
    row="match",
    aspect=2.5,
    height=2,
    hue="match",
    palette=cmap,
    legend_out=True,
    sharey=False,
    sharex=False,
)
g.map_dataframe(
    line_dist,
    x="smp_space",
    y="occp_norm",
    hue="match",
    palette=cmap,
    errorbar="se",
    err_style="bars",
    err_kws={"capsize": 1},
    area_alpha=0.05,
)
g.add_legend()
g.figure.savefig(
    os.path.join(FIG_PATH, "agg-line-sep.svg"), dpi=500, bbox_inches="tight"
)

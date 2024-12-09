# %% imports and definitions
import itertools as itt
import json
import os
import re
import warnings

import cv2
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import plotly.graph_objects as go
import scipy.stats as stats
import seaborn as sns
import xarray as xr
from matplotlib.ticker import MultipleLocator
from plotly.subplots import make_subplots
from scipy.io import loadmat
from scipy.stats import ttest_ind
from statannotations.Annotator import Annotator
from statannotations.stats.StatTest import StatTest
from tqdm.auto import tqdm

IN_DPATH = "./data"
IN_AXIS_LAB = "./data/axis_labels.json"
IN_REG_LAB = "./data/summer_ephys_ch_loc_coh.csv"
IN_CHN_LAB = "./data/channel_labels.json"
IN_GROUPS = ["control", "3wc", "3wp", "8wc", "8wp"]
IN_AGG_TYPE = ["full", "single"]
IN_VAR_LS = [t + "_" + g for t, g in itt.product(IN_AGG_TYPE, IN_GROUPS)]
FIG_PVAL = "./fig/pval/subplots"
FIG_PVAL_SEP = "./fig/pval/separate"
FIG_COH = "./fig/coherence"
CSV_COH = "./intermediate/output"
OUT_COH_PATH = "./intermediate/coherence"
OUT_PVAL_PATH = "./intermediate/pval"

os.makedirs(FIG_PVAL, exist_ok=True)
os.makedirs(FIG_PVAL_SEP, exist_ok=True)
os.makedirs(FIG_COH, exist_ok=True)
os.makedirs(CSV_COH, exist_ok=True)
os.makedirs(OUT_COH_PATH, exist_ok=True)
os.makedirs(OUT_PVAL_PATH, exist_ok=True)
warnings.filterwarnings("ignore")


def gaussian_smooth(im, sigma=1):
    kernel = np.zeros((5, 5))
    kernel[2, :] = cv2.getGaussianKernel(5, sigma).squeeze()
    kernel[:, 2] = cv2.getGaussianKernel(5, sigma).squeeze()
    mask = ~np.isnan(im)
    im_zp = np.nan_to_num(im)
    im_smth = cv2.filter2D(im_zp, -1, kernel, borderType=cv2.BORDER_REFLECT)
    im_wt = cv2.filter2D(mask.astype(float), -1, kernel, borderType=cv2.BORDER_REFLECT)
    return np.where(mask, im_smth / im_wt, np.nan)


# %% load data
files = os.listdir(IN_DPATH)
with open(IN_CHN_LAB) as jf:
    chn_lab = json.load(jf)["full"]
matfiles = list(filter(lambda f: f.endswith(".mat"), files))
single_arr_ls = []
full_arr_ls = []
full_arr_smth_ls = []
with open(IN_AXIS_LAB) as lab_json:
    labels = json.load(lab_json)
for mf in matfiles:
    mat = loadmat(os.path.join(IN_DPATH, mf), variable_names=IN_VAR_LS)
    freq = re.search(r"^full_ECHIP_coherence_(\w+)_track1.mat$", mf).group(1)
    for var in IN_VAR_LS:
        agg_type, group = re.search(r"^(\w+)_(\w+)$", var).groups()
        if group == "control":
            arr = xr.DataArray(
                np.concatenate(
                    [
                        mat["_".join([agg_type, "3wc"])],
                        mat["_".join([agg_type, "8wc"])],
                    ],
                    axis=-1,
                ),
                dims=["region", "region_", "animal"],
            )
        else:
            arr = xr.DataArray(mat[var], dims=["region", "region_", "animal"])
        arr = arr.assign_coords(freq=freq, agg_type=agg_type, group=group).expand_dims(
            ["freq", "agg_type", "group"]
        )
        if agg_type == "full":
            arr = arr.assign_coords(
                region=np.arange(arr.sizes["region"]) + 1,
                region_=np.arange(arr.sizes["region_"]) + 1,
                animal=np.arange(arr.sizes["animal"]),
            )
            full_arr_ls.append(arr)
            arr_smth = []
            for regA, regB in itt.product(chn_lab, chn_lab):
                arr_sub = arr.sel(
                    region=slice(*sorted(chn_lab[regA])),
                    region_=slice(*sorted(chn_lab[regB])),
                )
                asmth = xr.apply_ufunc(
                    gaussian_smooth,
                    arr_sub,
                    input_core_dims=[["region", "region_"]],
                    output_core_dims=[["region", "region_"]],
                    vectorize=True,
                )
                arr_smth.append(asmth)
            arr_smth = xr.combine_by_coords(arr_smth)
            full_arr_smth_ls.append(arr_smth)
        elif agg_type == "single":
            arr = arr.assign_coords(
                region=labels["single"],
                region_=labels["single"],
                animal=np.arange(arr.sizes["animal"]),
            )
            single_arr_ls.append(arr)
        else:
            raise ValueError(agg_type)
coherence = {
    "single": xr.combine_by_coords(single_arr_ls),
    "full": xr.combine_by_coords(full_arr_ls),
    "full_smth": xr.combine_by_coords(full_arr_smth_ls),
}
for agg_type, coh in coherence.items():
    coh.to_netcdf(os.path.join(OUT_COH_PATH, "{}.nc".format(agg_type)))

# %% calculate p values
single_pval_ls = []
full_pval_ls = []
full_smth_pval_ls = []
for agg_type, coh in tqdm(list(coherence.items()), desc="agg_type"):
    coh_mean = coh.mean("animal")
    coh_var = coh.var("animal", ddof=1)
    coh_ddof = coh.notnull().sum("animal")
    for grpA, grpB in tqdm(list(itt.combinations(IN_GROUPS, 2)), desc="comb"):
        meanA = coh_mean.sel(group=grpA)
        meanB = coh_mean.sel(group=grpB)
        varA = coh_var.sel(group=grpA)
        varB = coh_var.sel(group=grpB)
        ddofA = coh_ddof.sel(group=grpA)
        ddofB = coh_ddof.sel(group=grpB)
        vnA = varA / ddofA
        vnB = varB / ddofB
        # Welch's test
        sd = np.sqrt(vnA + vnB)
        t = (meanA - meanB) / sd
        ddof = sd**4 / (vnA**2 / (ddofA - 1) + vnB**2 / (ddofB - 1))
        pval = np.sign(t) * (
            (
                xr.apply_ufunc(
                    lambda t, df: stats.t.sf(t, df), np.abs(t), ddof, vectorize=True
                )
                * 2
            )
            .assign_coords(contrast="-".join([grpA, grpB]))
            .expand_dims("contrast")
        )
        if agg_type == "single":
            single_pval_ls.append(pval)
        elif agg_type == "full":
            full_pval_ls.append(pval)
        elif agg_type == "full_smth":
            full_smth_pval_ls.append(pval)
        else:
            raise ValueError(agg_type)
pval = {
    "single": xr.combine_by_coords(single_pval_ls),
    "full": xr.combine_by_coords(full_pval_ls),
    "full_smth": xr.combine_by_coords(full_smth_pval_ls),
}
for agg_type, pv in pval.items():
    pv.to_netcdf(os.path.join(OUT_PVAL_PATH, "{}.nc".format(agg_type)))


# %% plot p values
def make_heatmap(a: xr.DataArray, **kwargs):
    return go.Heatmap(x=a.coords["region"], y=a.coords["region_"], z=a, **kwargs)


CONTRAST_SUBSET = [
    "3wc-3wp",
    "8wc-8wp",
    "control-3wp",
    "control-8wp",
    "3wc-8wc",
    "3wp-8wp",
]
reg_lab = pd.read_csv(IN_REG_LAB).T.dropna().reset_index()
reg_lab.columns = ["lab", "loc"]
reg_lab["loc"] = reg_lab["loc"].astype(int)
reg_lab["reg_bound"] = reg_lab["lab"].apply(lambda l: l[-1]).astype(int)
reg_lab["lab"] = reg_lab["lab"].apply(lambda l: l[:-1])
reg_lab = reg_lab[reg_lab["reg_bound"] == 1].reset_index(drop=True)
reg_lab["center"] = (reg_lab["loc"] + np.append(reg_lab["loc"][1:].values, 189)) / 2
for agg_type in IN_AGG_TYPE:
    cur_coh = coherence[agg_type]
    cur_pval = np.abs(pval[agg_type].sel(contrast=CONTRAST_SUBSET))
    if agg_type == "single":
        exc_crd = cur_pval.coords["region"].values != "CA3so"
        cur_pval = cur_pval.sel(region=exc_crd, region_=exc_crd)
    for fq in cur_pval.coords["freq"].values:
        titles = []
        for con in cur_pval.coords["contrast"].values:
            a, b = con.split("-")
            titles.extend([a, b, "p-values"])
        fig = make_subplots(
            rows=cur_pval.sizes["contrast"],
            cols=3,
            subplot_titles=titles,
            shared_xaxes=True,
            shared_yaxes=True,
            horizontal_spacing=0.02,
            vertical_spacing=0.02,
        )
        for ic, con in enumerate(cur_pval.coords["contrast"].values):
            grpA, grpB = re.search(r"(\w+)-(\w+)", con).groups()
            fig.add_trace(
                make_heatmap(
                    cur_coh.sel(group=grpA, freq=fq).mean("animal").squeeze(),
                    coloraxis="coloraxis",
                ),
                row=ic + 1,
                col=1,
            )
            fig.add_trace(
                make_heatmap(
                    cur_coh.sel(group=grpB, freq=fq).mean("animal").squeeze(),
                    coloraxis="coloraxis",
                ),
                row=ic + 1,
                col=2,
            )
            fig.add_trace(
                make_heatmap(
                    cur_pval.sel(contrast=con, freq=fq).squeeze(),
                    coloraxis="coloraxis2",
                ),
                row=ic + 1,
                col=3,
            )
        fig.update_layout(
            autosize=False,
            width=1280,
            height=1900,
            coloraxis={"colorbar_x": -0.15},
            coloraxis2={"colorscale": "viridis_r", "cmin": 0, "cmax": 0.05},
        )
        fig.update_yaxes(autorange="reversed")
        if agg_type == "full":
            fig.update_yaxes(tickvals=reg_lab["center"], ticktext=reg_lab["lab"])
            fig.update_xaxes(tickvals=reg_lab["center"], ticktext=reg_lab["lab"])
            for b in reg_lab["loc"][1:].values:
                fig.add_hline(b, line={"color": "white", "dash": "dot", "width": 0.45})
                fig.add_vline(b, line={"color": "white", "dash": "dot", "width": 0.45})
        fig.write_html(os.path.join(FIG_PVAL, "{}-{}.html".format(agg_type, fq)))


# %% plot p values separately
def make_heatmap(a: xr.DataArray, **kwargs):
    return go.Heatmap(
        x=a.coords[a.dims[0]].values,
        y=a.coords[a.dims[1]].values,
        z=a.values,
        transpose=True,
        **kwargs
    )


CONTRAST_SUBSET = [
    "3wc-3wp",
    "8wc-8wp",
    "control-3wp",
    "control-8wp",
    "3wc-8wc",
    "3wp-8wp",
]
reg_lab = pd.read_csv(IN_REG_LAB).T.dropna().reset_index()
reg_lab.columns = ["lab", "loc"]
reg_lab["loc"] = reg_lab["loc"].astype(int)
reg_lab["reg_bound"] = reg_lab["lab"].apply(lambda l: l[-1]).astype(int)
reg_lab["lab"] = reg_lab["lab"].apply(lambda l: l[:-1])
reg_lab = reg_lab[reg_lab["reg_bound"] == 1].reset_index(drop=True)
reg_lab["center"] = (reg_lab["loc"] + np.append(reg_lab["loc"][1:].values, 189)) / 2
with open(IN_CHN_LAB) as jf:
    chn_lab = json.load(jf)
for agg_type in IN_AGG_TYPE:
    agg_coh = coherence[agg_type]
    agg_pval = np.abs(pval[agg_type].sel(contrast=CONTRAST_SUBSET))
    for fq in agg_pval.coords["freq"].values:
        for (labA, regA), (labB, regB) in itt.combinations_with_replacement(
            chn_lab[agg_type].items(), 2
        ):
            if agg_type == "full":
                locA, locB = (
                    reg_lab[reg_lab["loc"].between(*regA[::-1])],
                    reg_lab[reg_lab["loc"].between(*regB[::-1])],
                )
                regA, regB = slice(*regA[::-1]), slice(*regB[::-1])
            cur_pval = agg_pval.sel(region=regA, region_=regB)
            cur_coh = agg_coh.sel(region=regA, region_=regB)
            titles = []
            for con in cur_pval.coords["contrast"].values:
                a, b = con.split("-")
                titles.extend([a, b, "p-values"])
            fig = make_subplots(
                rows=cur_pval.sizes["contrast"],
                cols=3,
                subplot_titles=titles,
                shared_xaxes=False,
                shared_yaxes=False,
                horizontal_spacing=0.08,
                vertical_spacing=0.05,
            )
            for ic, con in enumerate(cur_pval.coords["contrast"].values):
                grpA, grpB = re.search(r"(\w+)-(\w+)", con).groups()
                fig.add_trace(
                    make_heatmap(
                        cur_coh.sel(group=grpA, freq=fq).mean("animal").squeeze(),
                        coloraxis="coloraxis",
                    ),
                    row=ic + 1,
                    col=1,
                )
                fig.add_trace(
                    make_heatmap(
                        cur_coh.sel(group=grpB, freq=fq).mean("animal").squeeze(),
                        coloraxis="coloraxis",
                    ),
                    row=ic + 1,
                    col=2,
                )
                fig.add_trace(
                    make_heatmap(
                        cur_pval.sel(contrast=con, freq=fq).squeeze(),
                        coloraxis="coloraxis2",
                    ),
                    row=ic + 1,
                    col=3,
                )
            fig_title = "{}-{}-{}_{}".format(agg_type, fq, labA, labB)
            fig.update_layout(
                title=fig_title,
                autosize=False,
                width=800,
                height=1300,
                coloraxis={"colorbar_x": -0.2},
                coloraxis2={"colorscale": "viridis_r", "cmin": 0, "cmax": 0.05},
            )
            fig.update_yaxes(autorange="reversed")
            if agg_type == "full":
                fig.update_yaxes(tickvals=reg_lab["center"], ticktext=reg_lab["lab"])
                fig.update_xaxes(tickvals=reg_lab["center"], ticktext=reg_lab["lab"])
                for b in locA["loc"][1:].values:
                    fig.add_vline(
                        b, line={"color": "white", "dash": "dot", "width": 0.45}
                    )
                for b in locB["loc"][1:].values:
                    fig.add_hline(
                        b, line={"color": "white", "dash": "dot", "width": 0.45}
                    )
            impath = os.path.join(FIG_PVAL_SEP, fig_title)
            fig.write_html("{}.html".format(impath))
            fig.write_image("{}.svg".format(impath), scale=2)


# %% define plotting function
def plot_coherence_pair(
    coh: xr.DataArray,
    groups: tuple,
    regions: tuple,
    freq: str,
    ylim: tuple,
    palette: dict = {
        "3wk-epileptic": "#e67067",
        "8wk-epileptic": "#800000",
        "3wk-control": "#103e9c",
        "8wk-control": "#103e9c",
        "control": "#103e9c",
    },
    group_dict: dict = {
        "3wp": "3wk-epileptic",
        "8wp": "8wk-epileptic",
        "3wc": "3wk-control",
        "8wc": "8wk-control",
    },
    **kwargs
):
    assert len(regions) == 2
    coh_sub = (
        coh.sel(freq=freq, region=regions[0], region_=regions[1])
        .rename("coherence")
        .squeeze()
        .to_dataframe()
        .reset_index()
    )
    coh_g = []
    for g in groups:
        if g == "control":
            cg = coh_sub[coh_sub["group"].isin(["3wc", "8wc"])].copy()
            cg["group"] = "control"
            coh_g.append(cg)
        else:
            coh_g.append(coh_sub[coh_sub["group"] == g])
    coh_g = pd.concat(coh_g, ignore_index=True).dropna().replace({"group": group_dict})
    sns.set(font_scale=2)
    sns.set_style("whitegrid")
    fig = plt.figure(figsize=(8, 6))
    ax = fig.add_subplot()
    sns.barplot(
        data=coh_g,
        x="group",
        y="coherence",
        hue="group",
        ax=ax,
        dodge=False,
        palette=palette,
        capsize=0.2,
        alpha=0.8,
    )
    ax = sns.swarmplot(
        data=coh_g,
        x="group",
        y="coherence",
        hue="group",
        color="black",
        ax=ax,
        alpha=0.7,
        size=8,
    )
    ax.get_legend().remove()
    ax.set(ylim=ylim)
    ax.yaxis.set_major_locator(MultipleLocator(0.2))
    ax.set_title(
        "regions: {}-{}, freq: {}".format(*regions, freq),
        fontdict={"fontweight": "bold"},
    )
    pairs = [p for p in itt.combinations(coh_g["group"].unique(), 2)]
    annotator = Annotator(
        ax, pairs, plot="barplot", data=coh_g, x="group", y="coherence"
    )
    test = StatTest(
        func=ttest_ind, test_long_name="", test_short_name="", equal_var=False
    )
    annotator.configure(test=test, text_format="simple")
    print(annotator.get_configuration())
    print(annotator.get_annotations_text())
    annotator.apply_and_annotate()
    fig.tight_layout()
    fig.savefig(os.path.join(FIG_COH, "_".join([*groups, *regions, freq]) + ".png"))
    coh_g.to_csv(os.path.join(CSV_COH, "_".join([*groups, *regions, freq]) + ".csv"))
    return fig


fig = plot_coherence_pair(
    coherence["single"],
    ("control", "3wp", "8wp"),
    ("Or", "Or"),
    "beta",
    (0.8, 1.1),
    dpi=500,
)

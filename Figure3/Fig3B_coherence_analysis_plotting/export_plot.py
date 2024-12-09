# %% imports and definitions
import json
import os
import re

import numpy as np
import pandas as pd
import plotly.graph_objects as go
import xarray as xr
from plotly.express.colors import diverging
from plotly.subplots import make_subplots

IN_REG_LAB = "./data/summer_ephys_ch_loc_coh.csv"
IN_CHN_LAB = "./data/channel_labels.json"
IN_COH_PATH = "./intermediate/coherence"
IN_PVAL_PATH = "./intermediate/pval"
IN_AGG_TYPE = ["full", "single", "full_smth"]
FIG_PATH = "./fig/export"
COLOR_DICT = {
    "control": "#103e9c",
    "3wp": "#e67067",
    "8wp": "#800000",
    "3wc": "#6794f0",
    "8wc": "#103e9c",
    "p-values": "black",
}
FONT_SIZE = 16
TITLE_SIZE = 24
os.makedirs(FIG_PATH, exist_ok=True)


def make_heatmap(a: xr.DataArray, **kwargs):
    return go.Heatmap(
        x=a.coords[a.dims[0]].values,
        y=a.coords[a.dims[1]].values,
        z=a.values,
        transpose=True,
        **kwargs
    )


def color_title(t):
    try:
        t["font"]["color"] = COLOR_DICT[t["text"]]
    except KeyError:
        try:
            t["text"] = "-".join(
                [
                    r"<span style='color: {}'>{}</span>".format(COLOR_DICT[e], e)
                    for e in t["text"].split("-")
                ]
            )
        except KeyError:
            t["font"]["color"] = "black"
    t["font"]["size"] = TITLE_SIZE
    t["text"] = "<b>{}</b>".format(t["text"])


# %% load data
coherence = {
    agg: xr.load_dataarray(os.path.join(IN_COH_PATH, "{}.nc".format(agg)))
    for agg in IN_AGG_TYPE
}
pval = {
    agg: xr.load_dataarray(os.path.join(IN_PVAL_PATH, "{}.nc".format(agg)))
    for agg in IN_AGG_TYPE
}
reg_lab = pd.read_csv(IN_REG_LAB).T.dropna().reset_index()
reg_lab.columns = ["lab", "loc"]
reg_lab["loc"] = reg_lab["loc"].astype(int)
reg_lab["reg_bound"] = reg_lab["lab"].apply(lambda l: l[-1]).astype(int)
reg_lab["lab"] = reg_lab["lab"].apply(lambda l: l[:-1])
reg_lab = reg_lab[reg_lab["reg_bound"] == 1].reset_index(drop=True)
reg_lab["center"] = (reg_lab["loc"] + np.append(reg_lab["loc"][1:].values, 189)) / 2
with open(IN_CHN_LAB) as jf:
    chn_lab = json.load(jf)

# %% plot coherence in three lines
CONTRAST_SUBSET = [
    "control-3wp",
    "control-8wp",
    "3wp-8wp",
]
AGG_TYPE_SUBSET = ["full", "full_smth"]
FREQ_SUBSET = ["theta", "gamma"]
REG_SUBSET = {
    "full": [("CA1DG", "CA1DG"), ("CA1DG", "MEC"), ("MEC", "MEC")],
    "full_smth": [("CA1DG", "CA1DG"), ("CA1DG", "MEC"), ("MEC", "MEC")],
}
SIG_LEVEL = 0.025

fig_path = os.path.join(FIG_PATH, "three_lines")
os.makedirs(fig_path, exist_ok=True)

for agg_type in AGG_TYPE_SUBSET:
    agg_coh = coherence[agg_type]
    agg_pval = np.abs(pval[agg_type].sel(contrast=CONTRAST_SUBSET))
    for fq in FREQ_SUBSET:
        for labA, labB in REG_SUBSET[agg_type]:
            if agg_type == "full_smth":
                regA, regB = chn_lab["full"][labA], chn_lab["full"][labB]
            else:
                regA, regB = chn_lab[agg_type][labA], chn_lab[agg_type][labB]
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
                vertical_spacing=0.12,
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
                height=800,
                coloraxis={
                    "colorbar_x": -0.22,
                    "colorbar_ticklabelposition": "outside left",
                },
                coloraxis2={
                    "colorscale": [
                        (0, "rgb(255,255,0)"),
                        (SIG_LEVEL, "rgb(255,255,102)"),
                        (SIG_LEVEL, "rgb(0,0,102)"),
                        (1, "rgb(0,0,102)"),
                    ],
                    "colorbar": {"tickvals": [0, SIG_LEVEL, 1]},
                    "cmin": 0,
                    "cmax": 1,
                },
                font_size=FONT_SIZE,
            )
            fig.update_yaxes(autorange="reversed")
            fig.update_xaxes(tickangle=-90)
            fig.for_each_annotation(color_title)
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
            impath = os.path.join(fig_path, fig_title)
            fig.write_image("{}.svg".format(impath), scale=2)

# %% plot coherence in two lines
GROUP_SUBSET = ["control", "3wp", "8wp"]
CONTRAST_SUBSET = [
    "control-3wp",
    "3wp-8wp",
    "control-8wp",
]
AGG_TYPE_SUBSET = ["full", "full_smth"]
FREQ_SUBSET = ["theta", "gamma"]
REG_SUBSET = {
    "full": [("CA1DG", "CA1DG"), ("CA1DG", "MEC"), ("MEC", "MEC")],
    "full_smth": [("CA1DG", "CA1DG"), ("CA1DG", "MEC"), ("MEC", "MEC")],
}
SIG_LEVEL = 0.05 / 3
# pval_cmap = diverging.oxy
pval_cmap = ["#C0392B", "#707B7C", "#73c2f5"]


def determine_sig(x):
    if ~np.isnan(x) and np.abs(x) < SIG_LEVEL:
        return np.sign(x)
    else:
        return 0


fig_path = os.path.join(FIG_PATH, "two_lines")
os.makedirs(fig_path, exist_ok=True)

for agg_type in AGG_TYPE_SUBSET:
    agg_coh = coherence[agg_type]
    agg_pval = pval[agg_type].sel(contrast=CONTRAST_SUBSET)
    for fq in FREQ_SUBSET:
        for labA, labB in REG_SUBSET[agg_type]:
            if agg_type == "full_smth":
                regA, regB = chn_lab["full"][labA], chn_lab["full"][labB]
            else:
                regA, regB = chn_lab[agg_type][labA], chn_lab[agg_type][labB]
            if agg_type == "full" or agg_type == "full_smth":
                locA, locB = (
                    reg_lab[reg_lab["loc"].between(*regA[::-1])],
                    reg_lab[reg_lab["loc"].between(*regB[::-1])],
                )
                regA, regB = slice(*regA[::-1]), slice(*regB[::-1])
            cur_pval = agg_pval.sel(region=regA, region_=regB)
            cur_coh = agg_coh.sel(region=regA, region_=regB)
            titles = GROUP_SUBSET + CONTRAST_SUBSET
            fig = make_subplots(
                rows=2,
                cols=cur_pval.sizes["contrast"],
                subplot_titles=titles,
                shared_xaxes=False,
                shared_yaxes=False,
                horizontal_spacing=0.1,
                vertical_spacing=0.2,
            )
            for ic, con in enumerate(cur_pval.coords["contrast"].values):
                fig.add_trace(
                    make_heatmap(
                        cur_coh.sel(group=GROUP_SUBSET[ic], freq=fq)
                        .mean("animal")
                        .squeeze(),
                        coloraxis="coloraxis",
                    ),
                    row=1,
                    col=ic + 1,
                )
                fig.add_trace(
                    make_heatmap(
                        xr.apply_ufunc(
                            determine_sig,
                            cur_pval.sel(contrast=con, freq=fq).squeeze(),
                            input_core_dims=[[]],
                            output_core_dims=[[]],
                            vectorize=True,
                        ),
                        coloraxis="coloraxis2",
                    ),
                    row=2,
                    col=ic + 1,
                )
            fig_title = "{}-{}-{}_{}".format(agg_type, fq, labA, labB)
            fig.update_layout(
                title=fig_title,
                autosize=False,
                width=1100,
                height=700,
                coloraxis={
                    "colorbar_len": 0.45,
                    "colorbar_y": 1.02,
                    "colorbar_yanchor": "top",
                },
                coloraxis2={
                    "colorscale": [
                        (0, pval_cmap[0]),
                        (0.33, pval_cmap[0]),
                        (0.33, pval_cmap[int(len(pval_cmap) / 2)]),
                        (0.66, pval_cmap[int(len(pval_cmap) / 2)]),
                        (0.66, pval_cmap[-1]),
                        (1, pval_cmap[-1]),
                    ],
                    "colorbar": {
                        "tickvals": [-1, 0, 1],
                        "ticktext": ["increased", "non-significant", "decreased"],
                        "len": 0.45,
                        "y": -0.02,
                        "yanchor": "bottom",
                    },
                    "cmin": -1.5,
                    "cmax": 1.5,
                },
                font_size=FONT_SIZE,
            )
            fig.update_yaxes(autorange="reversed")
            fig.update_xaxes(tickangle=-90)
            fig.for_each_annotation(color_title)
            if agg_type == "full" or agg_type == "full_smth":
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
            impath = os.path.join(fig_path, fig_title)
            fig.write_image("{}.svg".format(impath), scale=2)

# %% plot control groups only
GROUP_SUBSET = ["3wc", "8wc"]
CONTRAST_SUBSET = [
    "3wc-8wc",
    "control-3wc",
]
AGG_TYPE_SUBSET = ["full", "full_smth"]
FREQ_SUBSET = ["theta", "gamma"]
REG_SUBSET = {
    "full": [("CA1DG", "CA1DG"), ("CA1DG", "MEC"), ("MEC", "MEC")],
    "full_smth": [("CA1DG", "CA1DG"), ("CA1DG", "MEC"), ("MEC", "MEC")],
}
SIG_LEVEL = 0.05
# pval_cmap = diverging.oxy
pval_cmap = ["#C0392B", "#707B7C", "#73c2f5"]


def determine_sig(x):
    if ~np.isnan(x) and np.abs(x) < SIG_LEVEL:
        return np.sign(x)
    else:
        return 0


fig_path = os.path.join(FIG_PATH, "controls")
os.makedirs(fig_path, exist_ok=True)

for agg_type in AGG_TYPE_SUBSET:
    agg_coh = coherence[agg_type]
    agg_pval = pval[agg_type].sel(contrast=CONTRAST_SUBSET)
    for fq in FREQ_SUBSET:
        for labA, labB in REG_SUBSET[agg_type]:
            if agg_type == "full_smth":
                regA, regB = chn_lab["full"][labA], chn_lab["full"][labB]
            else:
                regA, regB = chn_lab[agg_type][labA], chn_lab[agg_type][labB]
            if agg_type == "full" or agg_type == "full_smth":
                locA, locB = (
                    reg_lab[reg_lab["loc"].between(*regA[::-1])],
                    reg_lab[reg_lab["loc"].between(*regB[::-1])],
                )
                regA, regB = slice(*regA[::-1]), slice(*regB[::-1])
            cur_pval = agg_pval.sel(region=regA, region_=regB)
            cur_coh = agg_coh.sel(region=regA, region_=regB)
            titles = GROUP_SUBSET + CONTRAST_SUBSET
            fig = make_subplots(
                rows=2,
                cols=cur_pval.sizes["contrast"],
                subplot_titles=titles,
                shared_xaxes=False,
                shared_yaxes=False,
                horizontal_spacing=0.1,
                vertical_spacing=0.2,
            )
            for ic, con in enumerate(cur_pval.coords["contrast"].values):
                fig.add_trace(
                    make_heatmap(
                        cur_coh.sel(group=GROUP_SUBSET[ic], freq=fq)
                        .mean("animal")
                        .squeeze(),
                        coloraxis="coloraxis",
                    ),
                    row=1,
                    col=ic + 1,
                )
                fig.add_trace(
                    make_heatmap(
                        xr.apply_ufunc(
                            determine_sig,
                            cur_pval.sel(contrast=con, freq=fq).squeeze(),
                            input_core_dims=[[]],
                            output_core_dims=[[]],
                            vectorize=True,
                        ),
                        coloraxis="coloraxis2",
                    ),
                    row=2,
                    col=ic + 1,
                )
            fig_title = "{}-{}-{}_{}".format(agg_type, fq, labA, labB)
            fig.update_layout(
                title=fig_title,
                autosize=False,
                width=750,
                height=700,
                coloraxis={
                    "colorbar_len": 0.45,
                    "colorbar_y": 1.02,
                    "colorbar_yanchor": "top",
                },
                coloraxis2={
                    "colorscale": [
                        (0, pval_cmap[0]),
                        (0.33, pval_cmap[0]),
                        (0.33, pval_cmap[int(len(pval_cmap) / 2)]),
                        (0.66, pval_cmap[int(len(pval_cmap) / 2)]),
                        (0.66, pval_cmap[-1]),
                        (1, pval_cmap[-1]),
                    ],
                    "colorbar": {
                        "tickvals": [-1, 0, 1],
                        "ticktext": ["increased", "non-significant", "decreased"],
                        "len": 0.45,
                        "y": -0.02,
                        "yanchor": "bottom",
                    },
                    "cmin": -1.5,
                    "cmax": 1.5,
                },
                font_size=FONT_SIZE,
            )
            fig.update_yaxes(autorange="reversed")
            fig.update_xaxes(tickangle=-90)
            fig.for_each_annotation(color_title)
            if agg_type == "full" or agg_type == "full_smth":
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
            impath = os.path.join(fig_path, fig_title)
            fig.write_image("{}.svg".format(impath), scale=2)

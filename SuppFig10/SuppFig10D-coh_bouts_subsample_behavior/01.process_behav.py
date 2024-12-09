#%% imports and definitions
import os

import numpy as np
import pandas as pd
import plotly.graph_objects as go
from tqdm.auto import tqdm

from routine.behav import label_track_trial
from routine.io import load_data
from routine.plotting import facet_plotly, vlines
from routine.utilities import arr_break_idxs

IN_DPATH = "./intermediate/processed"
PARAM_TRIAL_THRES = -2
PARAM_DS = 25000
FIG_PATH = "./figs/behav"

#%% process behavior variables
for dir_path in tqdm(os.listdir(IN_DPATH)):
    coord_path = os.path.join(IN_DPATH, dir_path, "coords", "smp_idx")
    pos = np.load(os.path.join(coord_path, "pos.npy"))
    track, trial = label_track_trial(pos, thres_trial=PARAM_TRIAL_THRES)
    np.save(os.path.join(coord_path, "track.npy"), track, allow_pickle=False)
    np.save(os.path.join(coord_path, "trial.npy"), trial, allow_pickle=False)

#%% plot behavior variables
fig_path = os.path.join(FIG_PATH, "positions")
os.makedirs(fig_path, exist_ok=True)
animals = pd.Series(os.listdir(IN_DPATH), name="animal").to_frame()
fig, layout = facet_plotly(
    animals,
    facet_row="animal",
    col_wrap=2,
    horizontal_spacing=0.01,
    vertical_spacing=0.01,
)
for (anm, _), ly in tqdm(list(layout.iterrows())):
    r, c = ly["row"] + 1, ly["col"] + 1
    ds = load_data(os.path.join(IN_DPATH, anm))
    df = (
        list(ds.values())[0]
        .coords.to_dataset()["smp_idx"]
        .sel(smp_idx=slice(0, None, PARAM_DS))
        .to_dataframe()
    )
    t1_idx = np.where(df["track"] == 1)[0]
    t2_idx = np.where(df["track"] == 2)[0]
    t1_s, t1_e = df.iloc[t1_idx[0]]["smp_idx"], df.iloc[t1_idx[-1]]["smp_idx"]
    if len(t2_idx) > 0:
        t2_s, t2_e = df.iloc[t2_idx[0]]["smp_idx"], df.iloc[t2_idx[-1]]["smp_idx"]
    brks = df["smp_idx"].iloc[arr_break_idxs(df["trial"].values)].values
    fig.add_trace(
        vlines(
            brks,
            ymin=-1,
            ymax=10,
            line_dash="dot",
            line_color="grey",
            line_width=1,
            hoverinfo="skip",
        ),
        row=r,
        col=c,
    )
    fig.add_trace(
        go.Scatter(
            x=df["smp_idx"],
            y=df["pos"],
            line={"color": "black"},
            customdata=df[["track", "trial"]],
            hovertemplate="pos: %{y:.1f}<br>track: %{customdata[0]}<br>trial: %{customdata[1]}",
            name="pos",
            showlegend=False,
        ),
        row=r,
        col=c,
    )
    fig.add_vrect(
        x0=t1_s,
        x1=t1_e,
        row=r,
        col=c,
        annotation_text="<b>track1</b>",
        annotation_position="top left",
        annotation_opacity=1,
        fillcolor="red",
        opacity=0.25,
        line_width=0,
    )
    if len(t2_idx) > 0:
        fig.add_vrect(
            x0=t2_s,
            x1=t2_e,
            row=r,
            col=c,
            annotation_text="<b>track2</b>",
            annotation_position="bottom left",
            annotation_opacity=1,
            fillcolor="blue",
            opacity=0.25,
            line_width=0,
        )
fig.update_xaxes(visible=False)
fig.update_yaxes(visible=False, fixedrange=True, range=[-0.5, 9])
fig.update_layout(height=5000, hovermode="x")
fig.write_html(os.path.join(fig_path, "positions.html"))

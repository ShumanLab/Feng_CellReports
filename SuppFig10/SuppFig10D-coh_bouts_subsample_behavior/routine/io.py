import functools as fct
import os

import numpy as np
import pandas as pd
import scipy.sparse as sps
import xarray as xr
from sparse import COO


def process_animal(
    out_path, pos, run_intervals, spikes, info, ch_map, ch_loc, smp_rate, ch_cols
):
    nsamp = len(pos)
    # process run interval
    run_intervals = (run_intervals[:2, :] * smp_rate).astype(int)
    assert np.max(run_intervals) <= nsamp
    run_intervals = pd.IntervalIndex.from_arrays(
        run_intervals[0, :], run_intervals[1, :], closed="both"
    )
    assert run_intervals.is_non_overlapping_monotonic
    behav = pd.DataFrame({"pos": pos, "isRunning": False})
    for t in run_intervals.to_tuples():
        behav.loc[slice(*t), "isRunning"] = True
    # process spikes
    spk_meta = []
    spk_arr = dict()
    for spk in spikes:
        shk = spk["shank"].unique().item()
        # generate sparse spike array
        sps_data, row_idx, col_idx = [], [], []
        for ir, row in spk.iterrows():
            spks = row["spiketimes"].copy()
            amps = row["amplitudes"]
            if not (info["t0"] == 0 and info["t1"] == 0):
                spks = spks + info["t0"] * smp_rate
                assert (spks <= info["t1"] * smp_rate).all()
            assert len(spks) == len(amps)
            for time, amp in zip(spks, amps):
                sps_data.append(amp)
                row_idx.append(ir)
                col_idx.append(time)
        sps_spk = sps.coo_array((sps_data, (row_idx, col_idx)), shape=(len(spk), nsamp))
        spk_arr[shk] = sps_spk
        assert sps_spk.nnz == spk["num_spikes"].sum()
        # generate channel metadata
        cmap = ch_map[ch_map["shank"] == shk].set_index("wrong")["updated"].to_dict()
        spk["channel"] = spk["highest_chan"].map(cmap)
        locs = ch_loc[ch_loc["Shank"] == int(shk[-1])][ch_cols]
        locs = (
            locs.squeeze()
            .dropna()
            .astype(int)
            .sort_values()
            .rename("channel")
            .to_frame()
            .reset_index()
        )
        locs["region"] = locs["index"].map(lambda r: r[:-1])
        locs = locs.groupby("region").apply(get_channel_interval).reset_index()
        locs = pd.IntervalIndex.from_arrays(
            left=locs["start"], right=locs["stop"], closed="both", name=locs["region"]
        )
        spk["region"] = spk["channel"].map(fct.partial(get_region, locs=locs))
        spk["neuron_type"] = spk.apply(classify_neuron, axis="columns")
        spk_meta.append(
            spk[
                [
                    "cluster_id",
                    "num_spikes",
                    "shank",
                    "channel",
                    "region",
                    "neuron_type",
                ]
            ]
        )
    spk_meta = pd.concat(spk_meta, ignore_index=True)
    spk_meta["animal"] = info["animal"]
    spk_meta["group"] = info["group"]
    # save
    crd_path = os.path.join(out_path, "coords", "smp_idx")
    os.makedirs(crd_path, exist_ok=True)
    np.save(os.path.join(crd_path, "pos.npy"), behav["pos"].values, allow_pickle=False)
    np.save(
        os.path.join(crd_path, "isRunning.npy"),
        behav["isRunning"].values,
        allow_pickle=False,
    )
    for shk, spk in spk_arr.items():
        sps.save_npz(os.path.join(out_path, "{}.npz".format(shk)), spk)
    spk_meta.to_feather(os.path.join(out_path, "spikes_meta.fea"))


def get_channel_interval(df):
    assert len(df) == 2
    ch0, ch1 = df["channel"].iloc[0], df["channel"].iloc[1]
    assert ch0 <= ch1
    return pd.Series({"start": ch0, "stop": ch1})


def get_region(channel, locs):
    try:
        return locs.name[locs.get_loc(channel)]
    except KeyError:
        return np.nan


def load_data(dpath, meta_only=False):
    spk_meta = pd.read_feather(os.path.join(dpath, "spikes_meta.fea"))
    if meta_only:
        return spk_meta
    coords = dict()
    for dirpath, dirs, files in os.walk(os.path.join(dpath, "coords")):
        for f in files:
            if f.endswith(".npy"):
                crd = np.load(os.path.join(dirpath, f))
                cname = f.rstrip(".npy")
            elif f.endswith("npz"):
                crd = sps.load_npz(os.path.join(dirpath, f)).toarray().squeeze()
                cname = f.rstrip(".npz")
            else:
                continue
            dim = dirpath.split(os.sep)[-1]
            coords[cname] = (dim, crd)
    arr_dict = dict()
    for shk, cur_meta in spk_meta.groupby("shank"):
        sps_arr = sps.load_npz(os.path.join(dpath, "{}.npz".format(shk)))
        sps_arr = xr.DataArray(
            COO(sps_arr),
            dims=["cluster_id", "smp_idx"],
            coords={
                **{
                    "cluster_id": cur_meta["cluster_id"],
                    "channel": ("cluster_id", cur_meta["channel"]),
                    "region": ("cluster_id", cur_meta["region"]),
                    "smp_idx": np.arange(sps_arr.shape[1], dtype=np.uint32),
                    "animal": cur_meta["animal"].unique().item(),
                    "group": cur_meta["group"].unique().item(),
                },
                **coords,
            },
            name=shk,
        )
        arr_dict[shk] = sps_arr
    return arr_dict


def classify_neuron(row):
    if row["exc"] == 1:
        return "excitatory"
    elif row["inh"] == 1:
        return "inhibitory"
    else:
        return "unclassified"

import warnings

import dask as da
import numpy as np
import pandas as pd
import sparse
import xarray as xr
from scipy.stats import gaussian_kde
from skimage.measure import label
from tqdm.auto import trange

from .utilities import (
    arr_break_idxs,
    corr_mat,
    df_map_values,
    df_notnull,
    df_set_metadata,
    qthres_sps,
)

pd.options.mode.use_inf_as_na = True


def compute_si(df, fr_name="fr_norm", occp_name="occp") -> float:
    fr, occp = df[fr_name].values, df[occp_name].values
    mfr = fr.mean()
    fr_norm = fr / mfr
    return (occp / occp.sum() * fr_norm * np.log2(fr_norm, where=fr_norm > 0)).sum()


def compute_stb(
    df, fr_name="fr_norm", trial_name="trial", space_name="smp_space"
) -> float:
    trials = np.sort(df[trial_name].unique())
    ntrial = len(trials)
    df["trial_idx"] = df[trial_name].map(
        {k: v for k, v in zip(trials, np.arange(ntrial))}
    )
    ntrial = ntrial - 1 if ntrial % 2 == 1 else ntrial
    df = df[df["trial_idx"] < ntrial].copy()
    if not len(df) > 0:
        return np.nan
    first = (
        df[df["trial_idx"] < ntrial / 2]
        .set_index([space_name, trial_name])[fr_name]
        .to_xarray()
        .values
    )
    last = (
        df[df["trial_idx"] >= ntrial / 2]
        .set_index([space_name, trial_name])[fr_name]
        .to_xarray()
        .values
    )
    odd = (
        df[df["trial_idx"] % 2 == 1]
        .set_index([space_name, trial_name])[fr_name]
        .to_xarray()
        .values
    )
    even = (
        df[df["trial_idx"] % 2 == 0]
        .set_index([space_name, trial_name])[fr_name]
        .to_xarray()
        .values
    )
    r_fl = corr_mat(first, last)
    r_oe = corr_mat(odd, even)
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", category=RuntimeWarning)
        return np.nanmean([r_fl, r_oe])


def compute_field(df, fr_name="fr_norm", q_thres=0.95) -> pd.DataFrame:
    fr = df[fr_name].values
    lab, nlab = label(fr > np.quantile(fr, q_thres), return_num=True)
    fd_len = 0
    fd_pos = np.nan
    for ilab in range(1, nlab + 1):
        cur_lab = lab == ilab
        cur_len = np.sum(cur_lab)
        if cur_len > fd_len:
            fd_len = cur_len
            fd_pos = np.argmax(np.where(cur_lab, fr, 0))
    return pd.DataFrame(
        {"metric": ["fd_len", "fd_pos"], "value": [fd_len, fd_pos]}
    ).set_index("metric")


def get_place_metrics(
    shk,
    occp,
    smp_space,
    bw_method,
    est_method="kde",
    weight_name="amp",
    meta=None,
    return_fr=True,
    pad_ref=None,
):
    fr_ls = []
    metric_ls = []
    for cid in shk.coords["cluster_id"].values:
        spks = shk.sel(cluster_id=cid)
        spks = spks.isel(smp_idx=np.unique(spks.data.nonzero()[0])).rename("amp")
        spks.data = spks.data.todense()
        if not len(spks) > 0:
            continue
        fr = est_by_track_trial(
            spks,
            var_name="pos",
            bw_method=bw_method,
            smp_space=smp_space,
            method=est_method,
            weight_name=weight_name,
            pad_ref=pad_ref,
        ).rename(columns={"pos": "fr"})
        fr = fr.merge(occp, on=["track", "trial", "smp_space"])
        fr["fr_norm"] = np.divide(
            fr["fr"], fr["occp"], out=np.zeros_like(fr["fr"]), where=fr["occp"] != 0
        )
        fr = (
            fr.groupby(["track", "trial"], group_keys=True)
            .apply(df_notnull)
            .reset_index(drop=True)
            .astype({"track": int, "trial": int})
        )
        fr_all = fr[fr["trial"] == -1].copy()
        fr_trial = fr[fr["trial"] != -1].copy()
        if not ((len(fr_all) > 0) and (len(fr_trial) > 0)):
            continue
        si = fr_all.groupby("track").apply(compute_si).rename("value").reset_index()
        stb = fr_trial.groupby("track").apply(compute_stb).rename("value").reset_index()
        fd = fr_all.groupby("track").apply(compute_field).reset_index()
        si["metric"] = "si"
        stb["metric"] = "stb"
        fr["cluster_id"] = cid
        si["cluster_id"] = cid
        stb["cluster_id"] = cid
        fd["cluster_id"] = cid
        fr_ls.append(fr)
        metric_ls.extend([si, stb, fd])
    if len(fr_ls) > 0 and len(metric_ls) > 0:
        fr = pd.concat(fr_ls, ignore_index=True)
        metric = pd.concat(metric_ls, ignore_index=True)
        if meta is not None:
            fr, metric = df_set_metadata([fr, metric], meta)
    else:
        fr, metric = pd.DataFrame(), pd.DataFrame()
    if return_fr:
        return fr, metric
    else:
        return metric


def est_by_track_trial(
    data: xr.DataArray,
    var_name: str,
    bw_method: float,
    smp_space: dict,
    weight_name: str = None,
    method="kde",
    pad_ref=None,
) -> pd.DataFrame:
    data = data.to_dataframe().reset_index()
    if pad_ref is not None:
        tracks = list(pad_ref["track"].unique())
        trials = list(set(pad_ref["trial"].unique()) - set([-1]))
        data["track"] = pd.Categorical(data["track"], categories=tracks)
        data["trial"] = pd.Categorical(data["trial"], categories=trials)
    ret_ls = []
    for track, dat_track in data.groupby("track"):
        if method == "hist":
            cur_est = hist_est(dat_track, var_name, smp_space[track], weight_name)
        elif method == "kde":
            cur_est = kde_est(
                dat_track, var_name, bw_method, smp_space[track], weight_name
            )
        cur_est["track"] = track
        cur_est["trial"] = -1
        if pad_ref is not None:
            cur_est = cur_est.fillna(0)
        ret_ls.append(cur_est)
        for trial, dat_trial in dat_track.groupby("trial"):
            if method == "hist":
                cur_est = hist_est(dat_trial, var_name, smp_space[track], weight_name)
            elif method == "kde":
                cur_est = kde_est(
                    dat_trial, var_name, bw_method, smp_space[track], weight_name
                )
            cur_est["track"] = track
            cur_est["trial"] = trial
            if pad_ref is not None:
                cur_est = cur_est.fillna(0)
            ret_ls.append(cur_est)
    ret = pd.concat(ret_ls)
    return ret


def hist_est(
    data: pd.DataFrame,
    var_name: str,
    smp_space: np.ndarray,
    weight_name: str = None,
) -> pd.DataFrame:
    if data[var_name].nunique() > 1:
        bins = np.linspace(smp_space[0], smp_space[-1], len(smp_space) + 1)
        if weight_name is not None:
            hist, _ = np.histogram(data[var_name], bins=bins, weights=data[weight_name])
        else:
            hist, _ = np.histogram(data[var_name], bins=bins)
        if hist.sum() == 0:
            hist = np.nan
    else:
        hist = np.nan
    return pd.DataFrame({"smp_space": smp_space, var_name: hist})


def kde_est(
    data: pd.DataFrame,
    var_name: str,
    bw_method: float,
    smp_space: np.ndarray,
    weight_name: str = None,
    zero_thres: float = 0.005,
) -> pd.DataFrame:
    dat = data[var_name]
    if dat.nunique() > 1:
        bounds = dat.min(), dat.max()
        if weight_name is not None:
            kernel = gaussian_kde(dat, bw_method=bw_method, weights=data[weight_name])
        else:
            kernel = gaussian_kde(dat, bw_method=bw_method)
        kde = kernel(smp_space)
        kde[kde < zero_thres] = 0
        kde[smp_space < bounds[0]] = 0
        kde[smp_space > bounds[1]] = 0
        if kde.sum() == 0:
            kde = np.nan
    else:
        kde = np.nan
    return pd.DataFrame({"smp_space": smp_space, var_name: kde})


def process_place_cells(
    shk,
    nbins=500,
    smp_space=None,
    est_method="kde",
    bw_method_occp=0.05,
    bw_method_fr=0.1,
    nshuf=10,
    downsample=1,
    binarize=False,
    thres=0.15,
    mem_limit=1024,
    n_workers=8,
    smp_rate=2.5e4,
):
    sub_idx = np.logical_and.reduce(
        (shk.coords["isRunning"], shk.coords["track"] > 0, shk.coords["trial"] > 0)
    )
    ds_idx = np.zeros_like(sub_idx, dtype=bool)
    ds_idx[np.arange(0, len(ds_idx), downsample)] = True
    pos = shk.coords["pos"].isel(smp_idx=np.logical_and(sub_idx, ds_idx))
    if smp_space is None:
        pos1, pos2 = pos.sel(smp_idx=pos.coords["track"] == 1), pos.sel(
            smp_idx=pos.coords["track"] == 2
        )
        smp_space = {1: np.linspace(pos1.min(), pos1.max(), nbins)}
        if len(pos2) > 0:
            smp_space[2] = np.linspace(pos2.min(), pos2.max(), nbins)
    occp = est_by_track_trial(
        pos.coords.to_dataset(),
        var_name="pos",
        bw_method=bw_method_occp,
        smp_space=smp_space,
        method=est_method,
    ).rename(columns={"pos": "occp"})
    occp["occp"] = occp["occp"] / (smp_rate / downsample)
    shk_sub = subset_nz(shk, sub_idx)
    if thres > 0:
        shk_sub.data = sparse.stack(
            [qthres_sps(x, thres) for x in shk_sub.data], axis=0
        )
    if binarize:
        shk_sub = shk_sub.astype(bool).astype(float)
    fr, metric = get_place_metrics(
        shk_sub,
        occp,
        smp_space,
        bw_method_fr,
        meta={"ishuf": -1},
        est_method=est_method,
        weight_name=None,
        pad_ref=occp,
    )
    metric_ls = []
    cur_ls = []
    for ishuf in trange(nshuf, leave=False):
        ntry = 0
        while ntry < 50:
            shk_shuf = subset_nz(shuffle_firing(shk), sub_idx)
            if thres > 0:
                shk_shuf.data = sparse.stack(
                    [qthres_sps(x, thres) for x in shk_shuf.data], axis=0
                )
            if binarize:
                shk_shuf = shk_shuf.astype(bool).astype(float)
            ntry += 1
            if shk_shuf.nbytes / (1024**2) < mem_limit:
                break
        else:
            raise RuntimeError("Cannot generate shuffled spike within memory limit")
        with da.annotate(resources={"MEM": 1}):
            metric_shuf = da.delayed(get_place_metrics)(
                shk_shuf,
                occp,
                smp_space,
                bw_method_fr,
                meta={"ishuf": ishuf},
                return_fr=False,
                est_method=est_method,
                weight_name=None,
                pad_ref=occp,
            )
        cur_ls.append(metric_shuf)
        if (ishuf + 1) % n_workers == 0 or ishuf >= nshuf - 1:
            cur_ls = da.compute(cur_ls, optimize_graph=False)[0]
            metric_ls.extend(cur_ls)
            cur_ls = []
    metric = pd.concat([metric, *metric_ls], ignore_index=True)
    fr, metric = df_set_metadata(
        [fr, metric],
        {"animal": shk.coords["animal"].item(), "group": shk.coords["group"].item()},
    )
    cl_info = shk.coords["cluster_id"].to_dataframe()
    fr, metric = df_map_values(
        [fr, metric],
        {
            "channel": ("cluster_id", cl_info["channel"].to_dict()),
            "region": ("cluster_id", cl_info["region"].to_dict()),
        },
    )
    return fr, metric


def subset_nz(arr: xr.DataArray, idxs: list):
    if type(idxs) is not list:
        idxs = [idxs]
    nz_idx = np.zeros_like(idxs[0], dtype=bool)
    nz_idx[np.unique(arr.data.sum(axis=0).nonzero()[0])] = True
    return arr.isel(smp_idx=np.logical_and.reduce([nz_idx, *idxs]))


def shuffle_firing(shk: xr.DataArray, by_track=True, by_trial=True) -> xr.DataArray:
    assert shk.dims == ("cluster_id", "smp_idx")
    brks = set([0, shk.sizes["smp_idx"]])
    if by_track:
        brks = brks.union(set(arr_break_idxs(shk.coords["track"].values).tolist()))
    if by_trial:
        brks = brks.union(set(arr_break_idxs(shk.coords["trial"].values).tolist()))
    brks = np.sort(list(brks))
    lefts = brks[:-1]
    rights = brks[1:]
    lengths = rights - lefts
    shifts = np.random.randint(lengths)
    shk_shuf = shk.copy()
    intv_idx = pd.cut(
        shk_shuf.data.coords[1, :], brks, labels=False, include_lowest=True
    )
    lefts_id = lefts[intv_idx]
    lengths_id = lengths[intv_idx]
    shifts_id = shifts[intv_idx]
    shk_shuf.data.coords[1, :] = (
        shk_shuf.data.coords[1, :] - lefts_id + shifts_id
    ) % lengths_id + lefts_id
    return shk_shuf


def classify_plc(df, sig, metrics):
    for met in metrics:
        df_sub = df[df["metric"] == met]
        val_org = np.array(df_sub[df_sub["ishuf"] == -1]["value"])
        if len(val_org) > 0:
            val_org = val_org.item()
        else:
            df[met + "_sig"] = False
            continue
        val_shuf = np.array(df_sub[df_sub["ishuf"] >= 0]["value"])
        if len(val_shuf) > 0:
            q = (val_org > val_shuf).mean()
            df[met + "_sig"] = q > sig
        else:
            df[met + "_sig"] = True
    return df

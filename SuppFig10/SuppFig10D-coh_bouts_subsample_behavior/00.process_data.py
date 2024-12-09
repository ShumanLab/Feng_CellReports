#%% imports and definition

import json
import os
import re

import h5py
import numpy as np
import pandas as pd
from scipy.io import loadmat
from tqdm.auto import tqdm

from routine.io import process_animal

IN_POS_PATH = "./data/position"
IN_RUN_PATH = "./data/runtime"
IN_ANM_PATH = "./data/animalinfo"
IN_SPK_PATH = "./data/spiketime"
IN_CHMAP_PATH = "./data/channelmap/channel_map.csv"
IN_CHLOC_PATH = "./data/channellocation/channel_location.csv"
IN_CHCOL_PATH = "./data/channellocation/channel_columns.json"
PARAM_SMP_RATE = 2.5e4
OUT_PATH = "./intermediate/processed"
os.makedirs(OUT_PATH, exist_ok=True)


#%% process behavior
ch_map = pd.read_csv(IN_CHMAP_PATH)
ch_loc = pd.read_csv(
    IN_CHLOC_PATH, skiprows=[1, 2, 3, 292, 293, 294, 295, 296, 297, 298]
)
with open(IN_CHCOL_PATH) as colf:
    ch_cols = json.load(colf)
for pos_file in tqdm(os.listdir(IN_POS_PATH)):
    anm = re.search(r"(.*)_position\.mat$", pos_file).group(1)
    ch_map_sub = ch_map[ch_map["animal"] == anm]
    ch_loc_sub = ch_loc[ch_loc["Animal"] == anm]
    spk_files = list(
        filter(lambda f: re.search(anm + r"_.*\.mat$", f), os.listdir(IN_SPK_PATH))
    )
    spikes = []
    for spkf in spk_files:
        meta = re.search(
            r"(?P<region>.*)_(?P<animal>.*)_(?P<shank>\d+)\.mat", spkf
        ).groupdict()
        spk = loadmat(os.path.join(IN_SPK_PATH, spkf))["unit"]
        try:
            spk_df = pd.DataFrame(spk.squeeze()).applymap(lambda x: x.squeeze())
        except ValueError:
            print("cannot load {}".format(spkf))
            continue
        assert (spk_df[["exc", "inh"]].sum(axis="columns") <= 1).all()
        spk_df["region"] = meta["region"]
        spk_df["shank"] = "shank{}".format(meta["shank"])
        spikes.append(spk_df)
    if not spikes:
        print("no spikes found for {}".format(anm))
        continue
    with h5py.File(os.path.join(IN_POS_PATH, pos_file)) as posf:
        pos = np.array(posf["position"]).squeeze()
    with h5py.File(os.path.join(IN_RUN_PATH, "{}_runtime.mat".format(anm))) as runf:
        run_intervals = np.array(runf["run_times"])
    with h5py.File(os.path.join(IN_ANM_PATH, "{}_exp.mat".format(anm))) as infof:
        info = pd.Series(
            {
                "animal": anm,
                "group": ch_loc_sub["Group"].unique().item(),
                "t0": np.array(infof["kilot0"]).item(),
                "t1": np.array(infof["kilot1"]).item(),
            }
        )
    outpath = os.path.join(OUT_PATH, anm)
    os.makedirs(outpath, exist_ok=True)
    process_animal(
        pos=pos,
        run_intervals=run_intervals,
        spikes=spikes,
        info=info,
        ch_map=ch_map_sub,
        ch_loc=ch_loc_sub,
        out_path=outpath,
        smp_rate=PARAM_SMP_RATE,
        ch_cols=ch_cols,
    )

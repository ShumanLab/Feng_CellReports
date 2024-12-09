#%% imports and definition
import os
import shutil

import pandas as pd

IN_DPATH = "/media/share/csstorage2/Susie/2020/Summer_Ephys_ALL/kilosort"
DST_PATH = "/media/share/csstorage2/Susie/2020/Summer_Ephys_ALL/analysis/place_coding/spiketime"
IN_MASTER = "/media/share/csstorage2/Susie/2020/Summer_Ephys_ALL/analysis/place_coding/channellocation/Summer Ephys Party ECHIP channel locations - Summer Ephys (1and3).csv"
DRY_RUN = False

#%% read csv
master_df = pd.read_csv(
    IN_MASTER, skiprows=[1, 2, 3, 292, 293, 294, 295, 296, 297, 298]
)
master_df = master_df[master_df["mastershank"].isin(["MEC", "CA1"])]

#%% copy file
for _, row in master_df.iterrows():
    anm, shk, reg = row["Animal"], row["Shank"], row["mastershank"]
    src = os.path.join(IN_DPATH, anm, "shank{}".format(shk), "cells.mat")
    dst = os.path.join(DST_PATH, "{}_{}_{}.mat".format(reg, anm, shk))
    if os.path.exists(src):
        print("{} -> {}".format(src, dst))
        if not DRY_RUN:
            shutil.copy2(src=src, dst=dst)
    else:
        raise FileNotFoundError("cannot find {}".format(src))

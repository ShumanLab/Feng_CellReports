import numpy as np


def label_track_trial(pos: np.ndarray, track1_hl=4, track2_ll=4.5, thres_trial=-2.5):
    track = np.zeros_like(pos, dtype=np.uint8)
    track2_idxs = np.where(pos >= track2_ll)[0]
    if len(track2_idxs) > 0:
        track2_start, track2_end = track2_idxs[0], track2_idxs[-1]
    else:
        track2_start, track2_end = pos.shape[0], pos.shape[0]
    track1_idxs = np.where(pos <= track1_hl)[0]
    track1_idxs = track1_idxs[track1_idxs < track2_start]
    track1_start, track1_end = track1_idxs[0], track1_idxs[-1]
    track[track1_start:track1_end] = 1
    track[track2_start:track2_end] = 2
    trial = np.zeros_like(pos, dtype=np.uint16)
    trial[track1_start:track1_end] = label_trial(
        pos[track1_start:track1_end], thres_trial
    )
    trial[track2_start:track2_end] = label_trial(
        pos[track2_start:track2_end], thres_trial
    )
    return track, trial


def label_trial(pos: np.ndarray, thres_trial):
    diff = np.diff(pos, prepend=True)
    breaks = np.where(diff < thres_trial)[0]
    trial = np.zeros_like(pos, dtype=np.uint16)
    for itrial, (start, stop) in enumerate(zip(breaks[:-1], breaks[1:])):
        trial[start:stop] = itrial + 1
    return trial

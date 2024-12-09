function [idx] = MECcluster_SF(r_scale_fac,e_M3r2CA1_c, e_M3mu2CA1_c)
    feat=[(e_M3r2CA1_c.*r_scale_fac).', e_M3mu2CA1_c.']; % r has to go first in here!!!!
    [idx,C] = kmedoids(feat,2,'distance', @wrap_distance); %sort into two clusters and return cluster centroid locations
end
function tab = rval_to_prism(anm_names, rvals)
    assert(all(size(anm_names) == size(rvals)), "length of animal must match length of r-values");
    anms = unique(anm_names);
    nanms = length(anms);
    nrows = 0;
    values = {};
    for anm = anms
        idx = strcmp(anm, anm_names);
        values(end+1) = {rvals(idx)};
        nval = sum(idx);
        if nval > nrows
            nrows = nval;
        end
    end
    tab = array2table(NaN(nrows, nanms), 'VariableNames', anms);
    for i = 1:nanms
        rv = values{i};
        tab(1:length(rv), i) = num2cell(rv');
    end
end
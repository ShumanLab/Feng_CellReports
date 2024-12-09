function wrap_d = wrap_distance(x, y)
    rdist = (x(:, 1) - y(:, 1)).^2;
    mudist_org = (x(:, 2) - y(:, 2)).^2;
    mudist_wrap = (wrapTo2Pi(x(:, 2)) - wrapTo2Pi(y(:, 2))).^2;
    mudist = min(mudist_org, mudist_wrap);
    wrap_d = sqrt(rdist + mudist);
end
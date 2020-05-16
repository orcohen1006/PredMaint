function y = normalize(x)
    y = x - mean(x);
%     yAbsMax = max(abs(y));
    sig = std(x);
    y = y./ sig;
end

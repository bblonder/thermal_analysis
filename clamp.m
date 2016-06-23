function [out] = clamp(in, lo, hi)
    in(in < lo) = NaN;
    in(in > hi) = NaN;
    
    out = in;
end
function [im_scaled] = rescale_image_range(im, lo, hi)
    im_scaled = (im - lo)/(hi-lo);
end

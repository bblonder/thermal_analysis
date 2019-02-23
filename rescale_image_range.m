function [im_scaled] = rescale_image_range(im, lo, hi)
    im_scaled = (im - lo)/(hi-lo);
    im_scaled(im_scaled < 0) = 0;
    im_scaled(im_scaled > 1) = 1;
end

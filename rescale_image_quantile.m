function [im_scaled] = rescale_image(im, qlo, qhi)
    lo = quantile(im(:),qlo);
    hi = quantile(im(:),qhi);
    im_scaled = (im - lo)/(hi-lo);
end

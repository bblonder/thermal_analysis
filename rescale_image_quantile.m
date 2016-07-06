function [im_scaled] = rescale_image(im, qlo, qhi)
    %imss = im(~isnan(im));
    imss = im(im>0);
    lo = quantile(imss(:),qlo);
    hi = quantile(imss(:),qhi);
    im_scaled = (im - lo)/(hi-lo);
end

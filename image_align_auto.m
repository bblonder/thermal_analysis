function [im_fused, im_visible_registered, points_thermal, points_visible] = image_align_auto(im_thermal, im_visible, points_thermal, points_visible)
    im_thermal = rgb2gray(im_thermal);
    im_visible = rgb2gray(im_visible);
    ptsOriginal  = detectSURFFeatures(im_thermal);
    ptsDistorted = detectSURFFeatures(im_visible);

    [featuresOriginal,   validPtsOriginal]  = extractFeatures(im_thermal,  ptsOriginal);
    [featuresDistorted, validPtsDistorted]  = extractFeatures(im_visible, ptsDistorted);  
    
    indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
    
    matchedOriginal  = validPtsOriginal(indexPairs(:,1));
    matchedDistorted = validPtsDistorted(indexPairs(:,2));

    figure;
    showMatchedFeatures(im_thermal,im_visible,matchedOriginal,matchedDistorted);
    title('Putatively matched points (including outliers)');
    
im_thermal = imcomplement(adapthisteq(rgb2gray(im_thermal)));
    im_visible = rgb2gray(im_visible);
    imshowpair(im_thermal, im_visible,'montage');
    [optimizer, metric] = imregconfig('multimodal');
    im_visible_registered = imregister(im_thermal, im_visible, 'affine',optimizer, metric);
    im_thermal_flipped = imcomplement(im_thermal);
    im_fused = imfuse(im_thermal_flipped, im_visible_registered(:,:,2),'ColorChannels',[1 2 0]);
    f = figure;
    imshow(im_fused);
end

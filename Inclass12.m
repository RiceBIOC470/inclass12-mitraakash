% Akash Mitra
% am132

%Inclass 12. 

% Continue with the set of images you used for inclass 11, the same time 
% point (t = 30)

stem_cell = '011917-wntDose-esi017-RI_f0016.tif';
stem_cell_reader = bfGetReader(stem_cell);

time = 30;
chan = 1;
zplane = sliceZ;
iplane = [];

for i=1:time;
    iplane = stem_cell_reader.getIndex(zplane-1, chan-1, i-1)+1;
end

img = bfGetPlane(stem_cell_reader, iplane);
imshow(img, [500 5000]);

%Reading Channel 2
time2 = 30;
chan2 = 2;
zplane2 = sliceZ;
iplane2 = [];

for i2=1:time2;
    iplane2 = stem_cell_reader.getIndex(zplane2-1, chan2-1, i2-1)+1;
end

img2 = bfGetPlane(stem_cell_reader, iplane2);
imshow(img2, [500 1500]);

img2show = cat(3, imadjust(img), imadjust(img2), zeros(size(img)));
imshow(img2show);

%Find brightest image first
im_bright = (2^16-1)*(img/max(max(img)));
imshow(im_bright, []);

%Convert brightest image to double - Probs not required
img_d = im2double(img);
img_bright = uint16( (2^16-1)*(img_d/max(max(img_d))));
imshow(img_bright);

%Making a series of binary masks

img_bw = img > 1000;
imshow(img_bw);

img_bw = img > 1500;
imshow(img_bw);

img_bw = img > 1775;
imshow(img_bw);

structure_el = strel('disk',3);

imshow(img_bw);
%Erosion Mask
imshow(imerode(img_bw, structure_el));

imshow(img_bw);
%Dilation Mask
imshow(imdilate(img_bw, structure_el));

% 1. Use the channel that marks the cell nuclei. Produce an appropriately
% smoothed image with the background subtracted. 

% Smoothening with a gaussian filter
rad = 10;
sigma = 3;
fgauss = fspecial('gaussian', rad, sigma);

img_smooth = imfilter(img2, fgauss);
imshow(img2, [500 1500]);

% Subtracting background
img2_sm = imfilter(img2, fspecial('gaussian',4,2));
img2_bg = imopen(img2_sm, strel('disk',100));
imshow(img2_bg,[]);

img2_sm_bgsub = imsubtract(img2_sm, img2_bg);
imshow(img2_sm_bgsub,[]);

% 2. threshold this image to get a mask that marks the cell nuclei.

%Find brightest image first
img2_bright = (2^16-1)*(img2/max(max(img2)));
imshow(img2_bright, []);

% Convert brightest image to double - Probs not required
% img2_d = im2double(img2);
% img2_bright = uint16( (2^16-1)*(img2_d/max(max(img2_d))));
% imshow(img2_bright);

% img_bw = img2_bright > 65000;
% imshow(img_bw);

img_bw = img2 > 1000;
imshow(img_bw);

% 3. Use any morphological operations you like to improve this mask (i.e.
% no holes in nuclei, no tiny fragments etc.)

% % morphological opening
% img_open = imopen(img_bw, strel('disk',10));
% imshow(img_open);
% 
% imshow(cat(3,img_bw,img_open,zeros(size(img_bw))));
% 
% % morphological close
% img_close = imclose(img_bw, strel('disk',10));
% imshow(img_close);
% 
% imshow(cat(3,img_bw,img_close,zeros(size(img_bw))));

% dilation on intensity
img_dilate = imdilate(img2, strel('disk',5));
imshow(img_dilate, [500 5000]);

subplot(1,2,1), imshow(img2, [500 5000]), title('Original Image');

subplot(1,2,2), imshow(img_dilate, [500 5000])
title('Morphologically improved image')

% rad = 10;
% sigma = 3;
% fgauss = imgaussfilt(img2, 3);
% %lap = fspecial('laplacian', 0.1);
% 
% subplot(1,2,1), imshow(img2, [500 5000]), title('Original Image');
% 
% subplot(1,2,2), imshow(fgauss, [500 5000])
% title('Gaussian filtered image, \sigma = 2')
% 
% img_smooth = imfilter(img2, fgauss);
% imshow(img2, [500 5000]);
% 
% img_smooth = imfilter(img2, lap);
% imshow(img2, [500 5000]);
% 
% fsobel = fspecial('sobel');
% 
% img_sobel = imfilter(img_smooth, fsobel');
% imshow(img_sobel, [500 5000]);


% 4. Use the mask together with the images to find the mean intensity for
% each cell nucleus in each of the two channels. Make a plot where each data point 
% represents one nucleus and these two values are plotted against each other

measurements = regionprops( img_bw,img2, 'MeanIntensity');
measurements2 = regionprops( img_bw,img_dilate, 'MeanIntensity');

mes1 = struct2dataset(measurements);
mes2 = struct2dataset(measurements2);
plot(mes1,mes2,'o'); 
xlabel('Img1 Mean Intensity');
ylabel('Img2 Mean Intensity');

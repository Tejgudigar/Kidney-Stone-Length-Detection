clc
clear all
close all
warning off

% Define pixels per millimeter (example value, you need to calibrate this)
pixelsPerMM = 10; % Replace this with the actual value

% Load and display the image
[filename, pathname] = uigetfile('*.*', 'Pick a MATLAB code file');
filename = strcat(pathname, filename);
a = imread(filename);
imshow(a);
title('Original Image');

% Convert to grayscale and display
b = rgb2gray(a);
figure;
imshow(b);
title('Grayscale Image');
impixelinfo;

% Binarize the image and display
c = b > 10;
figure;
imshow(c);
title('Binary Image');

% Fill holes and display
d = imfill(c, 'holes');
figure;
imshow(d);
title('Hole Filled Image');

% Remove small objects and display
e = bwareaopen(d, 1000);
figure;
imshow(e);
title('Small Objects Removed');

% Preprocess the image and display
%Adding 50: This shifts all the pixel values in the adjusted image up by 50 units
PreprocessedImage = uint8(double(a) .* repmat(e, [1 1 3]));
figure;
imshow(PreprocessedImage);
title('Preprocessed Image');

% Adjust image intensity values or contrast.
PreprocessedImage = imadjust(PreprocessedImage, [0.3 0.7], []) + 50;
figure;
imshow(PreprocessedImage);
title('Adjusted Image');

% Convert to grayscale and display
uo = rgb2gray(PreprocessedImage);
figure;
imshow(uo);
title('Gray Adjusted Image');

% Apply median filter and display  to remove noise.
mo = medfilt2(uo, [5 5]);
figure;
imshow(mo);
title('Median Filtered Image');

% Further binarize and display
po = mo > 250;
figure;
imshow(po);
title('Final Binary Image');

% Define region of interest
[r, c, ~] = size(po); %r=row, c=col, ~=placeholder for 3D
x1 = r / 2;           %set to the middle of the image's height.
y1 = c / 3;           %set to one-third of the image's width.
row = [x1 x1+200 x1+200 x1];    %vertical rectangle starting at x1 and extending 200 pixels downward.
col = [y1 y1 y1+40 y1+40];      %horizontal rectangle starting at y1 and extending 40 pixels to the right.
BW = roipoly(po, row, col);
figure;
imshow(BW);
title('Region of Interest');

% Apply mask and display
k = po .* double(BW);
figure;
imshow(k);
title('Masked Image');

% Remove small objects and label connected components
M = bwareaopen(k, 4);
[ya, number] = bwlabel(M);

if number >= 1
    disp('Stone is Detected');
    % Measure properties of image regions
    stats = regionprops(M, 'MajorAxisLength');
    % Convert length from pixels to millimeters
    stoneLengthPixels = max([stats.MajorAxisLength]);
    stoneLengthMM = stoneLengthPixels / pixelsPerMM;
    disp(['Length of the detected stone: ', num2str(stoneLengthMM), ' mm']);
else
    disp('No Stone is detected');
end

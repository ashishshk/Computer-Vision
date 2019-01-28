% Debugging tip: You can split your MATLAB code into cells using "%%"
% comments. The cell containing the cursor has a light yellow background,
% and you can press Ctrl+Enter to run just the code in that cell. This is
% useful when projects get more complex and slow to rerun from scratch

close all; % closes all figures

%% Setup
% read images and convert to floating point format

image1 = im2single(imread('Data/marilyn.bmp'));
image2 = im2single(imread('Data/einstein.bmp'));
A = imread('Data/cat.bmp');
B = imread('Data/dog.bmp');
gray1 = rgb2gray(A);
gray2 = rgb2gray(B);
image3 = im2single(gray1);
image4 = im2single(gray2);
gray5 = rgb2gray(imread('Data/bicycle.bmp'));
gray6 = rgb2gray(imread('Data/motorcycle.bmp'));
image5 = im2single(gray6);
image6 = im2single(gray5);



% Several additional test cases are provided for you, but feel free to make
% your own (you'll need to align the images in a photo editor such as
% Photoshop). The hybrid images will differ depending on which image you
% assign as image1 (which will provide the low frequencies) and which image
% you asign as image2 (which will provide the high frequencies)

%% Filtering and Hybrid Image construction
cutoff_frequency_1 =7;
cutoff_frequency_2 = 3;
%This is the standard deviation, in pixels, of the 
% Gaussian blur that will remove the high frequencies from one image and 
% remove the low frequencies from another image (by subtracting a blurred
% version from the original version). You will want to tune this for every
% image pair to get the best results.
filter1 = fspecial('Gaussian', cutoff_frequency_1*2+1, cutoff_frequency_1);
filter2 = fspecial('Gaussian', cutoff_frequency_2*2+1, cutoff_frequency_2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE BELOW. Use imfilter() to create 'low_frequencies' and
% 'high_frequencies' and then combine them to create 'hybrid_image'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the high frequencies from image1 by blurring it. The amount of
% blur that works best will vary with different image pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

low_frequencies1 = imfilter(image1 , filter1);
low_frequencies2 = imfilter(image4 , filter1);
low_frequencies3 = imfilter(image5 , filter1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the low frequencies from image2. The easiest way to do this is to
% subtract a blurred version of image2 from the original version of image2.
% This will give you an image centered at zero with negative values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blurredimage1 = imfilter(image2 , filter2);

high_frequencies1 = image2 - blurredimage1;

blurredimage2 = imfilter(image3 , filter2);

high_frequencies2 = image3 - blurredimage2;

blurredimage3 = imfilter(image6 , filter2);

high_frequencies3 = image6 - blurredimage3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine the high frequencies and low frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hybrid_image1 = low_frequencies1 + high_frequencies1;
hybrid_image2 = low_frequencies2 + high_frequencies2;
hybrid_image3 = low_frequencies3 + high_frequencies3;

%% Visualize and save outputs
figure(1); imshow(low_frequencies1)
figure(2); imshow(high_frequencies1 + 0.5);
figure(3); imshow(hybrid_image1);
figure(4); imshow(low_frequencies2)
figure(5); imshow(high_frequencies2 + 0.5);
figure(6); imshow(hybrid_image2);
figure(7); imshow(low_frequencies3)
figure(8); imshow(high_frequencies3 + 0.5);
figure(9); imshow(hybrid_image3);
%vis = vis_hybrid_image(hybrid_image);
%figure(3); imshow(vis);
% imwrite(low_frequencies, 'low_frequencies.jpg', 'quality', 95);
% imwrite(high_frequencies + 0.5, 'high_frequencies.jpg', 'quality', 95);
% imwrite(hybrid_image, 'hybrid_image.jpg', 'quality', 95);
% %imwrite(vis, 'hybrid_image_scales.jpg', 'quality', 95);



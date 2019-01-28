% Debugging tip: You can split your MATLAB code into cells using "%%"
% comments. The cell containing the cursor has a light yellow background,
% and you can press Ctrl+Enter to run just the code in that cell. This is
% useful when projects get more complex and slow to rerun from scratch

close all; % closes all figures

%% Setup
% read images and convert to floating point format
A = imread('Data/cat.bmp');
B = imread('Data/dog.bmp');
gray1 = rgb2gray(A);
figure(8)
imshow(gray1)
gray2 = rgb2gray(B);
figure(9)
imshow(gray2)
image1 = im2single(gray1);
image2 = im2single(gray2);

% Several additional test cases are provided for you, but feel free to make
% your own (you'll need to align the images in a photo editor such as
% Photoshop). The hybrid images will differ depending on which image you
% assign as image1 (which will provide the low frequencies) and which image
% you asign as image2 (which will provide the high frequencies)

%% Filtering and Hybrid Image construction
cutoff_frequency_1 = 7;
cutoff_frequency_2 = 4;
%This is the standard deviation, in pixels, of the 
% Gaussian blur that will remove the high frequencies from one image and 
% remove the low frequencies from another image (by subtracting a blurred
% version from the original version). You will want to tune this for every
% image pair to get the best results.
filter1 = fspecial('Gaussian', cutoff_frequency_1*4+1, cutoff_frequency_1);
filter2 = fspecial('Gaussian', cutoff_frequency_2*4+1, cutoff_frequency_2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE BELOW. Use imfilter() to create 'low_frequencies' and
% 'high_frequencies' and then combine them to create 'hybrid_image'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the high frequencies from image1 by blurring it. The amount of
% blur that works best will vary with different image pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

low_frequencies = imfilter(image2 , filter2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the low frequencies from image2. The easiest way to do this is to
% subtract a blurred version of image2 from the original version of image2.
% This will give you an image centered at zero with negative values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blurredimage1 = imfilter(image1 , filter1);

high_frequencies = image1 - blurredimage1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine the high frequencies and low frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hybrid_image = low_frequencies + high_frequencies;

%% Visualize and save outputs
figure(1); imshow(low_frequencies)
figure(2); imshow(high_frequencies + 0.5);
figure(3); imshow(hybrid_image);
vis = vis_hybrid_image(hybrid_image);
figure(4); imshow(vis);
imwrite(low_frequencies, 'low_frequencies.jpg', 'quality', 95);
imwrite(high_frequencies + 0.5, 'high_frequencies.jpg', 'quality', 95);
imwrite(hybrid_image, 'hybrid_image.jpg', 'quality', 95);
imwrite(vis, 'hybrid_image_scales.jpg', 'quality', 95);

%%FFT


% figure(5); A = imagesc(log(abs(fftshift(fft2(gray1)))))
% figure(6); B = imagesc(log(abs(fftshift(fft2(gray2)))))
% figure(7); C = imagesc(log(abs(fftshift(fft2(low_frequencies)))))
% figure(8); D = imagesc(log(abs(fftshift(fft2(high_frequencies)))))
% figure(9); E = imagesc(log(abs(fftshift(fft2(hybrid_image)))))
figure(5);
colormap(jet);
subplot(1,5,1), title('Image1'),
A = imagesc(log(abs(fftshift(fft2(gray1)))))
subplot(1,5,2),
B = imagesc(log(abs(fftshift(fft2(gray2)))))
subplot(1,5,3),
C = imagesc(log(abs(fftshift(fft2(low_frequencies)))))
subplot(1,5,4),
D = imagesc(log(abs(fftshift(fft2(high_frequencies)))))
subplot(1,5,5),
E = imagesc(log(abs(fftshift(fft2(hybrid_image)))))

%colormap(winter);
%%vis_hybrid_image

function output = vis_hybrid_image(hybrid_image)
%visualize a hybrid image by progressively downsampling the image and
%concatenating all of the images together.

scales = 5; %how many downsampled versions to create
scale_factor = 0.5; %how much to downsample each time
padding = 5; %how many pixels to pad.

original_height = size(hybrid_image,1);
num_colors = size(hybrid_image,3); %counting how many color channels the input has
output = hybrid_image;
cur_image = hybrid_image;

for i = 2:scales
    %add padding
    output = cat(2, output, ones(original_height, padding, num_colors));
    
    %dowsample image;
    cur_image = imresize(cur_image, scale_factor, 'bilinear');
    %pad the top and append to the output
    tmp = cat(1,ones(original_height - size(cur_image,1), size(cur_image,2), num_colors), cur_image);
    output = cat(2, output, tmp);    
end
end


%code by James Hays



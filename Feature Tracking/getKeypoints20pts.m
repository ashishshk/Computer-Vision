function [keyXs, keyYs] = getKeypoints20pts(im, tau)
% Detecting keypoints using Harris corner criterion  

% im: input image
% tau: threshold

% keyXs, keyYs: detected keypoints, with dimension [Number of 
% keypoints] x [2]

% YOUR CODE HERE

%im = im2double(imread('hotel.seq0.png'));

% cutoff =7;
filt = fspecial('gaussian');
rad =1;
order = 2*rad+1;
%tau = 0.0002;

% 
% filteredim = imfilter(double(im),filt);

%imagesc(filteredim)
%colormap gray;

[Ix , Iy] = gradient(im);


Ix2 = Ix.*Ix; 
Iy2 = Iy.*Iy;
Ixy = Ix.*Iy;

Ix2 = imfilter(Ix2,filt);
Iy2 = imfilter(Iy2,filt);
Ixy = imfilter(Ixy,filt);


harrisR = (Ix2.*Iy2 - Ixy.^2) ./ (Ix2 + Iy2);

nonmaxSup = ordfilt2(harrisR , order^2 , ones(order));
harrisR = (harrisR == nonmaxSup) & (harrisR > tau);

[keyXs , keyYs] = find(harrisR);

% For 20 random points
[rowsize,~] = size(keyXs);
pts20 = randperm(rowsize);
keyXs = keyXs(pts20(1:20));
keyYs = keyYs(pts20(1:20));


figure(1);
imshow(im);
hold on;
plot(keyYs,keyXs,'.g','linewidth',3)

 
end
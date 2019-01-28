function featureMatching
% Matching SIFT Features

im1 = imread('stop1.jpg');
im2 = imread('stop2.jpg');

load('SIFT_features.mat'); % Load pre-computed SIFT features
% Descriptor1, Descriptor2: SIFT features from image 1 and image 2
% Frame1, Frame2: position, scale, rotation of keypoints

% YOUR CODE HERE

%Read the input images
im1 = imread('stop1.jpg');
im2 = imread('stop2.jpg');

load('SIFT_features.mat');

tic
%kd - tree implimentation 
mdl = createns(Descriptor1','NSMethod','kdtree');
i  = knnsearch(mdl,Descriptor2','K',2);
matches = [[380:2:400]',i(380:2:400,1)];
toc
figure(1); 
plotmatches(im2double(im1),im2double(im2),Frame1,Frame2,matches');
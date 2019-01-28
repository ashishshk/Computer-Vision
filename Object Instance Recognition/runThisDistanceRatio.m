function featureMatching
% Matching SIFT Features

im1 = imread('stop1.jpg');
im2 = imread('stop2.jpg');

load('SIFT_features.mat'); % Load pre-computed SIFT features
% Descriptor1, Descriptor2: SIFT features from image 1 and image 2
% Frame1, Frame2: position, scale, rotation of keypoints

% YOUR CODE HERE

[a1 ,b1] = size(Descriptor1);
[a2 ,b2] = size(Descriptor2);

% Defining some threshold tau
tau = 0.6;
pt = 0;

% Defining the distance array
distance = zeros(1,b2);

for i = 1:b1
    for j = 1:b2
        distance(j) = sqrt(sum(Descriptor1(:,i) - Descriptor2(:,j)).^2);
    end
    
    [a3, b3] = min(distance);
    
% Now, we need to sort the distance array

    sorted_distance = sort(distance);
    ratio = sorted_distance(1)/sorted_distance(2);
    
    if ratio < tau
        pt = pt + 1;
        matches(1,pt) = i;
        matches(2,pt) = b3;
        
    end
end        

% matches: a 2 x N array of indices that indicates which keypoints from image
% 1 match which points in image 2

% Display the matched keypoints
figure(1), hold off, clf
plotmatches(im2double(im1),im2double(im2),Frame1,Frame2,matches);
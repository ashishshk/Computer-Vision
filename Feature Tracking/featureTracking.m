function featureTracking
% Main function for feature tracking
folder = 'images';
im = readImages(folder, 0:50);
tau = 0.0002;                               % Threshold for harris corner detection
[pt_x, pt_y] = getKeypoints(im{1}, tau);    % Prob 1.1: keypoint detection

ws = 7;                                     % Tracking ws x ws patches
[track_x, track_y] = ...                    % Keypoint tracking
    trackPoints(pt_x, pt_y, im, ws);
  
% Visualizing the feature tracks on the first and the last frame
figure(2), imagesc(im{1}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r', 'linewidth', 3);
figure(3), imagesc(im{end}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r', 'linewidth', 3);

end


function [track_x, track_y] = trackPoints(pt_x, pt_y, im, ws)
% Tracking initial points (pt_x, pt_y) across the image sequence
% track_x: [Number of keypoints] x [2]
% track_y: [Number of keypoints] x [2]

% Initialization
N = numel(pt_x);
nim = numel(im);
track_x = zeros(N, nim);
track_y = zeros(N, nim);
track_x(:, 1) = pt_x(:);
track_y(:, 1) = pt_y(:);

for t = 1:nim-1
    [track_x(:, t+1), track_y(:, t+1)] = ...
            getNextPoints(track_x(:, t), track_y(:, t), im{t}, im{t+1}, ws);
end
end


function [x2, y2] = getNextPoints(x, y, im1, im2, ws)
% Iterative Lucas-Kanade feature tracking
% x,  y : initialized keypoint position in im1
% x2, y2: tracked keypoint positions in im2
% ws: patch window size

% YOUR CODE HERE

[points,rand] = size(x);

[a1,b1] = size(im1);
[a2,b2] = size(im2);

x2 = x;
y2 = y;

hw = floor(ws/2);

iter1 = points;
iter2 = 5;
% count = 1;

for i = 1:1:points
    [Ix1 , Iy1] = imgradientxy(im1);
    [X , Y] = meshgrid((-hw+x(i)):(hw+x(i)) , (-hw+y(i)):(hw+y(i)));
    
    if (-hw+x(i))<0 || (hw+x(i))>b1 || (-hw+y(i))<0 || (hw+y(i))>a1
        continue;
    end
    
    % Grabbing patch1
    patch1 = interp2(im1 ,X ,Y);
    Ix1 = interp2(Ix1 ,X ,Y);
    Iy1 = interp2(Iy1 ,X ,Y);
    
    for j = 1:1:iter2
       if (-hw +x2(i))<0 || (hw +x2(i))>b2 || (-hw +y2(i))<0 || (hw +y2(i))>a2
%              outpnt(count) = i;
%              count = count + 1;
             continue;
       end
       patch2 = interp2(im2 ,X ,Y);
       It = patch2 - patch1;
       A = [Ix1(:) Iy1(:)];
       b = -It(:);
       
       d = A\b;
       
       x2(i) = x2(i) + d(1);
       y2(i) = y2(i) + d(2);
       
    end
end
end
       

    

function im = readImages(folder, nums)
im = cell(numel(nums),1);
t = 0;
for k = nums   
    t = t+1;
    im{t} = imread(fullfile(folder, ['hotel.seq' num2str(k) '.png']));
    im{t} = im2single(im{t});
end
end

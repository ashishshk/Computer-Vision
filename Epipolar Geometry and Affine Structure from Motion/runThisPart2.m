function F = HW3_SfM
close all;

folder = 'images/';
im = readImages(folder, 0:50);

load './tracks.mat';

%track_x = track_x(:,10:end);
%track_y = track_y(:,10:end);
figure(2), imagesc(im{1}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r')
figure(3), imagesc(im{end}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r', 'linewidth',3)
%pause;

valid = ~any(isnan(track_x), 2) & ~any(isnan(track_y), 2); 

[R, S] = affineSFM(track_x(valid, :), track_y(valid, :));

plotSfM(R, S);




function [R, S] = affineSFM(x, y)
% Function: Affine structure from motion algorithm

% Normalize x, y to zero mean
xn = zeros(size(x,1),size(x,2));
yn = zeros(size(y,1),size(y,2));
for i = 1:size(x,2)
    xn(:,i) = x(:,i) - mean(x(:,i));
    yn(:,i) = y(:,i) - mean(y(:,i));
end
% Create measurement matrix
D = [xn' ; yn'];

% Decompose and enforce rank 3
% Compute SVD: D = UWVT:
[U,W,V] = svd(D);

U3 = U(:,1:3);
W3 = W(1:3,1:3);
V3 = V(:,1:3);

% Create the motion(affine) matrix:
% Using sqrtm for matrix square root
A = U3*sqrtm(W3);

% Create the shape(3D) matrix:
% Using sqrtm for matrix square root
S = sqrtm(W3)*V3';

a1 = A(1:i,:);
a2 = A(i+1:end,:);
amain = zeros(3*i,9);
m = zeros(i,1);
for k = 1:i
    amain(k,:) = reshape(a1(k,:)'*a1(k,:),[1 9]);
    amain(k+i,:) = reshape(a2(k,:)'*a2(k,:),[1 9]);
    amain(k+(2*i),:) = reshape(a1(k,:)'*a2(k,:),[1 9]);
    m(k) = 1;
    m(k+i) = 1;
    m(k+(2*i)) = 0;
end;
L = reshape(amain\m,[3 3]);
% Using Cholesky factorization
C = chol(L,'upper')
A = A*C;
S = (C')*S;
R = A;

    

% Apply orthographic constraints


function im = readImages(folder, nums)
im = cell(numel(nums),1);
t = 0;
for k = nums,
    t = t+1;
    im{t} = imread(fullfile(folder, ['hotel.seq' num2str(k) '.png']));
    im{t} = im2single(im{t});
end

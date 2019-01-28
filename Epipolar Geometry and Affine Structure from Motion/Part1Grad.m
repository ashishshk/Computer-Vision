function F = HW3_FundamentalMatrix
close all;

im1 = im2double(imread('chapel00.png'));
im2 = im2double(imread('chapel01.png'));
load 'matches.mat';

[F, inliers, normF, normInliers] = ransacF(c1(matches(:, 1)), r1(matches(:, 1)), c2(matches(:, 2)), r2(matches(:, 2)), im1, im2);

% display F
F
normF
unitF1 = F/sqrt(sum(sum(F.^2)))
%For Normalized F
unitF2 = normF/sqrt(sum(sum(normF.^2)))
outliers_1 = setdiff(1:size(matches,1),inliers);
outliers_2 = setdiff(1:size(matches,1),normInliers);

size(outliers_1)
size(outliers_2)
% plot outliers
figure(1)
plotmatches(im1,im2,[c1 r1]',[c2 r2]',matches');
figure(2)
plotmatches(im1,im2,[c1 r1]',[c2 r2]',matches(inliers,:)');

figure(7)
plotmatches(im1,im2,[c1 r1]',[c2 r2]',matches');
figure(8)
plotmatches(im1,im2,[c1 r1]',[c2 r2]',matches(normInliers,:)');



% display epipolar lines
rand = randsample(size(inliers,2),7);
pts1 = inliers(rand);

rand = randsample(size(normInliers,2),7);
pts2 = normInliers(rand);

% figure(3)
% imshow(im1);
% hold on;

figure(9)
imshow(im1);
hold on;

% figure(4)
% imshow(im2);
% hold on;

figure(10)
imshow(im2);
hold on;
for i = 1:size(pts1,2)
    imMatches = matches(pts1(i),:);
    x1 = c1(imMatches(1));
    x2 = c2(imMatches(2));
    y1 = r1(imMatches(1));
    y2 = r2(imMatches(2));

    

    lineF1 = unitF1 * [x2 y2 1]';
    lineF2 = unitF1 * [x1 y1 1]';
    x1Line = 1:0.1:550;
    y1Line = -(lineF1(1)*x1Line + lineF1(3))/lineF1(2);    

    x2Line = 1:0.1:550;
    y2Line = -(lineF2(1)*x2Line + lineF2(3))/lineF2(2);
    
%     figure(3)    
%     hold on;
%     scatter(x1,y1,'r+');
%     plot(x1Line,y1Line,'g');

%     figure(4)   
%     hold on;
%     scatter(x2,y2,'r+');
%     plot(x2Line,y2Line,'g');
end;

for i = 1:size(pts2,2)
    imMatches = matches(pts2(i),:);
    x1 = c1(imMatches(1));
    x2 = c2(imMatches(2));
    y1 = r1(imMatches(1));
    y2 = r2(imMatches(2));

    

    lineF1 = unitF2 * [x2 y2 1]';
    lineF2 = unitF2 * [x1 y1 1]';
    x1Line = 1:0.1:550;
    y1Line = -(lineF1(1)*x1Line + lineF1(3))/lineF1(2);    

    x2Line = 1:0.1:550;
    y2Line = -(lineF2(1)*x2Line + lineF2(3))/lineF2(2);
    
    figure(9)    
    hold on;
    scatter(x1,y1,'r+');
    plot(x1Line,y1Line,'g');

    figure(10)   
    hold on;
    scatter(x2,y2,'r+');
    plot(x2Line,y2Line,'g');
end;

figure(5);
inlierPoints = matches(inliers,:);
outlierPoints = matches(outliers_1,:);
imshow(im1);
hold on;
scatter(c1(outlierPoints(:,1)),r1(outlierPoints(:,1)),'g.')
scatter(c1(inlierPoints(:,1)),r1(inlierPoints(:,1)),'r.')


figure(11);
inlierPoints = matches(normInliers,:);
outlierPoints = matches(outliers_2,:);
imshow(im1);
hold on;
scatter(c1(outlierPoints(:,1)),r1(outlierPoints(:,1)),'g.')
scatter(c1(inlierPoints(:,1)),r1(inlierPoints(:,1)),'r.')

function [bestF, best, normF, norm] = ransacF(x1, y1, x2, y2, im1, im2)

% Find normalization matrix
T1 = normalize(x1, y1);
T2 = normalize(x2, y2);

% Transform point set 1 and 2
x1_store = [x1 y1 ones(size(x1))];
x2_store = [x2 y2 ones(size(x2))];

x1pts = (T1*x1_store')';
x2pts = (T2*x2_store')';
% RANSAC based 8-point algorithm
bestCountInliers1 = 3;
bestCountInliers2 = 3;
for i = 1:1000
    % Select 8 random points
    randIndex = randsample(size(x1,1),8);
    
    
    F1 = computeF(x1pts(randIndex,:),x2pts(randIndex,:));
    F2 = computeF(x1_store(randIndex,:),x2_store(randIndex,:));
    inliers1 = getInliers(x1pts, x2pts, F1, 0.1);
    inliers2 = getInliers(x1_store, x2_store, F2, 4);
    cntInliers1(i) = size(inliers1,2);
    cntInliers2(i) = size(inliers2,2);
    
    if cntInliers1(i)>bestCountInliers1
        rightF1 = F1;
        rightInliers1 = inliers1;
        bestCountInliers1 = cntInliers1(i);
        %figure(3), hold off, plotmatches(im1, im2, x1Pts(:, 1:2)', x2Pts(:, 1:2)', [inliers inliers]'); 
    end
    
    if cntInliers2(i)>bestCountInliers2
        rightInliers2 = inliers2;
        bestCountInliers2 = cntInliers2(i);
        %figure(3), hold off, plotmatches(im1, im2, x1Pts(:, 1:2)', x2Pts(:, 1:2)', [inliers inliers]'); 
    end
end
bestF = T2'*rightF1*T1;
best = rightInliers1;

normF = rightF1;
norm = rightInliers2;



function inliers = getInliers(pt1, pt2, F, threshold)
% Function: implement the criteria checking inliers. 
for i = 1:size(pt1,1)
    lineTemp1 = F*pt1(i,:)';
    lineTemp2 = F*pt2(i,:)';
    distX1(i) = abs(pt1(i,:)*lineTemp2)/sqrt(lineTemp2(1)^2+lineTemp2(2)^2);
    distX2(i) = abs(pt2(i,:)*lineTemp1)/sqrt(lineTemp1(1)^2+lineTemp1(2)^2);

end

 %err = mean(distX1)
 %normerr = mean(distX1)
inliers = find(distX1<threshold & distX2<threshold);

function T = normalize(x, y)
% Function: find the transformation to make it zero mean and the variance as sqrt(2)
T = [1/std(x) 0 0 ; 0 1/std(y) 0 ; 0 0 1]*[1 0 -mean(x) ; 0 1 -mean(y) ; 0 0 1];

  
function F = computeF(x1,x2)
% Function: compute fundamental matrix from corresponding points
A = [x1(:,1).*x2(:,1) x1(:,1).*x2(:,2) x1(:,1) x1(:,2).*x2(:,1) x1(:,2).*x2(:,2) x1(:,2) x2(:,1) x2(:,2) ones(size(x1,1),1)];
[~, ~, V] = svd(A);
f = V(:, end);
F = reshape(f, [3 3])';
[U, S, V] = svd(F);
S(3,3) = 0; 
F = U*S*V';

function F = HW3_FundamentalMatrix
close all;

im1 = im2double(imread('chapel00.png'));
im2 = im2double(imread('chapel01.png'));
load 'matches.mat';

[F, inliers] = ransacF(c1(matches(:, 1)), r1(matches(:, 1)), c2(matches(:, 2)), r2(matches(:, 2)), im1, im2);

% display F
F;
unitnormF = F/sqrt(sum(sum(F.^2)))
outliers = setdiff(1:size(matches,1),inliers);
size(outliers)

% display epipolar lines
size(inliers);
randIndex = randsample(size(inliers,2),7);
pointsToPlot = inliers(randIndex);

figure(3)
imshow(im1);
hold on;

figure(4)
imshow(im2);
hold on;
for i = 1:size(pointsToPlot,2)
    matchesIM = matches(pointsToPlot(i),:);
    x1 = c1(matchesIM(1));
    x2 = c2(matchesIM(2));
    y1 = r1(matchesIM(1));
    y2 = r2(matchesIM(2));

    

    lineF1 = unitnormF * [x2 y2 1]';
    lineF2 = unitnormF * [x1 y1 1]';
    x1Line = 1:0.1:550;
    y1Line = -(lineF1(1)*x1Line + lineF1(3))/lineF1(2);    

    x2Line = 1:0.1:550;
    y2Line = -(lineF2(1)*x2Line + lineF2(3))/lineF2(2);
    
    figure(3)    
    hold on;
    scatter(x1,y1,'r+');
    plot(x1Line,y1Line,'g');

    figure(4)   
    hold on;
    scatter(x2,y2,'r+');
    plot(x2Line,y2Line,'g');
end;

figure(5);
inlierPoints = matches(inliers,:);
outlierPoints = matches(outliers,:);
imshow(im1);
hold on;
scatter(c1(outlierPoints(:,1)),r1(outlierPoints(:,1)),'g.')
scatter(c1(inlierPoints(:,1)),r1(inlierPoints(:,1)),'r+')





function [bestF, best] = ransacF(x1, y1, x2, y2, im1, im2)

% Find normalization matrix
T1 = normalize(x1, y1);
T2 = normalize(x2, y2);

% Transform point set 1 and 2
x1PtsTemp = [x1 y1 ones(size(x1))];
x2PtsTemp = [x2 y2 ones(size(x2))];

x1Pts = x1PtsTemp;
x2Pts = x2PtsTemp;

% RANSAC - 8-point algorithm
bestInliers = 2;
for i = 1:1000
    rand = randsample(size(x1,1),8);
    
    
    F = generateF(x1Pts(rand,:),x2Pts(rand,:));
    inliers = getInliers(x1Pts, x2Pts, F, 10);
    countInliers(i) = size(inliers,2);
    
    
    if countInliers(i)>bestInliers
        rF = F;
        rInliers = inliers;
        bestInliers = countInliers(i);
        %figure(3), hold off, plotmatches(im1, im2, x1Pts(:, 1:2)', x2Pts(:, 1:2)', [inliers inliers]'); 
    end;
end
bestF = rF;
%bestF = T2'*rightF*T1;
%bestF = T1'*rightF*T2;
best = rInliers;



function inliers = getInliers(pt1, pt2, F, threshold)
% Function: implement the criteria checking inliers. 
for i = 1:size(pt1,1)
    l1 = F*pt1(i,:)';
    l2 = F*pt2(i,:)';
    distX1(i) = abs(pt1(i,:)*l2)/sqrt(l2(1)^2+l2(2)^2);
    distX2(i) = abs(pt2(i,:)*l1)/sqrt(l1(1)^2+l1(2)^2);

end

inliers = find(distX1<threshold & distX2<threshold);

function T = normalize(x, y)
% Function: find the transformation to make it zero mean and the variance as sqrt(2)
T = [1/std(x) 0 0 ; 0 1/std(y) 0 ; 0 0 1]*[1 0 -mean(x) ; 0 1 -mean(y) ; 0 0 1];

  
function F = generateF(x1,x2)
% Function: compute fundamental matrix from corresponding points
A = [x1(:,1).*x2(:,1) x1(:,1).*x2(:,2) x1(:,1) x1(:,2).*x2(:,1) x1(:,2).*x2(:,2) x1(:,2) x2(:,1) x2(:,2) ones(size(x1,1),1)];
[U, S, V] = svd(A);
f = V(:, end);
F = reshape(f, [3 3])';
[U, S, V] = svd(F);
S(3,3) = 0; 
F = U*S*V';

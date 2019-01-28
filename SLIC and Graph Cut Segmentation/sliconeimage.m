%function [cIndMap, time, imgVis] = slic(img, K, compactness)

%% Implementation of Simple Linear Iterative Clustering (SLIC)
%
% Input:
%   - img: input color image
%   - K:   number of clusters
%   - compactness: the weights for compactness
% Output: 
%   - cIndMap: a map of type uint16 storing the cluster memberships
%     cIndMap(i, j) = k => Pixel (i,j) belongs to k-th cluster
%   - time:    the time required for the computation
%   - imgVis:  the input image overlaid with the segmentation

% Put your SLIC implementation here
tic;
% Input data
img =imread('dog.jpg');
imgB   = im2double(img);
cform  = makecform('srgb2lab');
imgLab = applycform(imgB, cform);

% Initialize cluster centers (equally distribute on the image). Each cluster is represented by 5D feature (L, a, b, x, y)
% Hint: use linspace, meshgrid
% SLIC superpixel segmentation
% In each iteration, we update the cluster assignment and then update the cluster center

[c1, r1, rgb] = size(img);
% N = r1*c1;
K= 256;
% S = round(sqrt(N/K));
S = round(sqrt((r1*c1)/K));
%twoS = S * 2;
xCent = round(linspace(S, (c1-S), (((c1-S) - S)/S)));
yCent = round(linspace(S, (r1-S), (((r1-S) - S)/S)));

[c2, r2] = meshgrid(xCent, yCent);
c2 = reshape(c2, 1, []);
r2 = reshape(r2, 1, []);
imgCent = imgLab(c2, r2, :);
c = 1;
for i = 1: size(c2, 2)

    meanmat(c, 1) = imgCent(i, i, 1);
    meanmat(c, 2) = imgCent(i, i, 2);
    meanmat(c, 3) = imgCent(i, i, 3);
    meanmat(c, 4) = c2(c);
    meanmat(c, 5) = r2(c);
    c = c + 1;
end

  % for a = 1:r1
%     for b = 1:c1
%         l(a,b) = -1;
%         d(a,b) = Inf;
%     end
% end

% distance d
d = ones(c1, r1) * Inf;
% label l
l = ones(c1, r1) * -1;

numIter = 10; % Number of iteration for running SLIC
for iter = 1: numIter
    for a = 1:size(meanmat, 1)
        lc = round(meanmat(a, 4) - (S-1));
        hc = round(meanmat(a, 4) + (S-1));
        lr = round(meanmat(a, 5) - (S-1));
        hr = round(meanmat(a, 5) + (S-1));

        if lc < 1
            lc = 1;
        end

 
        if hc > c1
        hc = c1;
        end

         if lr < 1
             lr = 1;
         end

        if hr > r1
        hr = r1;
        end

        for b = lc:hc
              for c = lr:hr

   pix = [imgLab(b, c, 1) imgLab(b, c, 2) imgLab(b, c, 3) b c];
   distn = distMeasure(50, S, pix, meanmat(a, :));

                if distn < d(b, c)
                    d(b, c) = distn;
                    l(b, c) = a;
                end
              end
        end
     end

 

    for e = 1:size(meanmat, 1)
        [c3, r3] = find(l==e);

        for iter2 = 1:size(c3, 1)
            temp(iter2, :) = [imgLab(c3(iter2), r3(iter2), 1), imgLab(c3(iter2), r3(iter2), 2), imgLab(c3(iter2), r3(iter2), 3), c3(iter2), r3(iter2)];
        end
    LAB = mean(temp, 1);
    meanmat(e, :) = LAB;
    
    
    end
% if numIter == 1
%     figure(2);
%     imagesc(distn);
% end


    if iter == 1
        figure();
        imagesc(d);
        title('Error map before Convergence');
    end
    
    if iter == 10
        figure();
        imagesc(d);
        title('Error map after Convergence');
    end

end

figure(3);
imagesc();
time = toc;
% Visualize mean color image

cIndMap = l;
[gx, gy] = gradient(cIndMap);
bMap = (gx.^2 + gy.^2) > 0;
imgVis = img;
imgVis(cat(3, bMap, bMap, bMap)) = 1;
cIndMap = uint16(cIndMap);
imagesc(imgVis)
time
%end

function D = distMeasure(m, S, g, h)
dc = sqrt(((g(1)-h(1))^2) + ((g(2)-h(2))^2) + ((g(3)-h(3))^2));
ds = sqrt(((g(4)-h(4))^2) + ((g(5)-h(5))^2));
%Calculate the final distance measure:
D = sqrt(dc^2 + ((ds/S)^2 * m^2));
end


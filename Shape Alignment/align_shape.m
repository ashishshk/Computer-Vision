function T = align_shape(im1, im2)

% im1: input edge image 1
% im2: input edge image 2

% Output: transformation T [3] x [3]

% YOUR CODE HERE

% First, we need to extract the shape by finding the non zero points

[Y1, X1] = find(im1 > 0);
[Y2, X2] = find(im2 > 0);

% Now, finding the mean for each image

meanX1 = mean(X1);
meanY1 = mean(Y1);
meanX2 = mean(X2);
meanY2 = mean(Y2);

% Finding the scale by calculating the average distance from the mean

first_scale = mean(sqrt(((X1 - meanX1).^2)+(Y1 - meanY1).^2));
second_scale = mean(sqrt(((X2 - meanX2).^2)+(Y2 - meanY2).^2));

scale = second_scale/first_scale;

% Computing the initial transformation T

    T = [1 0 meanX2 ; 0 1 meanY2 ; 0 0 1]*[scale 0 0 ; 0 scale 0 ; 0 0 1]*...
        [1 0 -meanX1 ; 0 1 -meanY1 ; 0 0 1];

[m,~] = size(X1);
[n,~] = size(X2);
dist = zeros(n,1);
A = zeros(2*m,6);
b = zeros(2*m,1);
points = ones(3,m);
points(1,:) = X1;
points(2,:) = Y1;
storePoints = points;


for k= 1:1:50
    points = T*storePoints;
    for i=1:1:m
        for j=1:1:n
        % Calculating the Eucldian distance value
        dist(j) = sqrt((points(1,i) - X2(j))^2 + (points(2,i) - Y2(j))^2);
        end
        [p,q]= min(dist);
        %Computing the transportation matrix
        A(2*i-1,1) = X1(i);
        A(2*i-1,2) = Y1(i);
        A(2*i,3) = X1(i);
        A(2*i,4) = Y1(i);
        A(2*i-1,5) = 1;
        A(2*i,6) = 1;
        b(2*i-1)= X2(q);
        b(2*i)= Y2(q);
    end
    t = A\b;
    T = [t(1,1) t(2,1) t(5,1); t(3,1) t(4,1) t(6,1); 0 0 1];
end

end




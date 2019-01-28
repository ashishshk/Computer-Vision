load gs.mat;
load sift_desc.mat;

tic
desc = zeros(128,20*1888);
len = length(train_D);
for i = 1:len
    train_D{i} = double(train_D{i});
    desc1 = train_D{i};
    index = randi([1 size(desc1,2)],1,20);
    if i == 1
        first = 1;
        last = 20;
    else
        first = (i - 1) * 20 + 1;
        last = first + 19;
    end
    desc(:, first:last) = desc1(:, index);
end

K = 100;
C = kmeans(desc', K);
C = C';

toc;

trainbag = zeros(K, 1888);
len = length(train_D);
for i=1:len
    desc1 = double(train_D{i});
    [dist, index] = min(pdist2(C',desc1'));
    for j=1:length(index)
        trainbag(index(j),i) = trainbag(index(j),i) + 1;
    end
    trainbag(:,i) = trainbag(:,i)./length(index); 
end


testbag = zeros(K, 800);
for i=1:length(test_D)
    desc1 = double(test_D{i});
    [dist, index] = min(pdist2(C',desc1'));
    for j=1:length(index)
        testbag(index(j),i) = testbag(index(j),i) + 1;
    end
    testbag(:,i) = testbag(:,i)./length(index); 
end


load gs.mat;

tic
knn(testbag, trainbag);
toc;

function knn(testbag, trainbag)
load gs.mat;
predmat = [];
for i=1:size(testbag, 2)
    t = testbag(:,i);
    [distance, index] = min(pdist2(t', trainbag'));
    predmat = [predmat train_gs(index)];
end

confusion = confusionmat(test_gs, predmat)
accuracy = trace(confusion)/sum(sum(confusion))*100
end

function C = kmeans(X, K)

% Initialize cluster centers to be randomly sampled points
[N, d] = size(X);
rp = randperm(N);
C = X(rp(1:K),:);

lastAssignment = zeros(N, 1);

for i = 1:300
    bestAssignment = zeros(N,1);
    mindist = Inf*ones(N,1);
    [dist, k] = min(pdist2(C,X), [], 1);
    
    t = dist' < mindist;
    mindist = dist';
    bestAssignment(t) = k';

if all(bestAssignment == lastAssignment), break; 
end

for k = 1:K
    C(k,:) = mean(X(bestAssignment==k,:));
end
    lastAssignment = bestAssignment;
end
end

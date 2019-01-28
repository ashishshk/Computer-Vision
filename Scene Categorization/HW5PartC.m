K = 100;

load gs.mat
load sift_desc.mat

trainim = length(train_gs);
testim = length(test_gs);
noofcats = 8;
 
 
% Load training data
traindesc = zeros(128,413971);
t = 1;
for i = 1:1888
    traindesc(:,t:t+size(train_D{i},2)-1) = ...
        double(train_D{i});
    t = t+size(train_D{i},2);
end
 
testdesc = zeros(128,177634);
t = 1;
for i = 1:800
    testdesc(:,t:t+size(test_D{i},2)-1) = double(test_D{i});
    t = t + size(test_D{i},2);
end
 
 
% initializing the clusters
 
clusterIndices = [];
for cat = 1:8
        clusterIndices = [clusterIndices ...
        find(train_gs == cat, 15)];
end
 

clusterImages = train_D(clusterIndices);
numD = 0;
for i = 1:length(clusterIndices)
    numD = numD + size(clusterImages{i},2);
end


desc = zeros(128,numD);

t = 1;
for i = 1:length(clusterIndices)
    desc(:,t:t+size(clusterImages{i},2)-1) = ...
        double(clusterImages{i});
    t = t+size(clusterImages{i},2);
end
 
initClusters = zeros(128,noofcats*K);
for i = 1:noofcats
    index = find(train_gs == i,10);
    clusterImages = train_D(index);
    numD = 0;
    for j = 1:length(index)
        numD = numD + size(clusterImages{j},2);
    end
    desc = zeros(128,numD);
    init = 1;
    for j = 1:length(index)
        ending = init +size(clusterImages{j},2) - 1;
        desc(:,init:ending) = double(clusterImages{j});
        init = ending+1;
    end
    ind = randperm(size(desc,2),K);
    initClusters(:,(i-1)*K+1:i*K) = desc(:,ind);
end
index = randperm(noofcats*K,K);
initClusters = initClusters(:,index);
 
 
% Final clusters % 
clusters = initClusters;
numDescriptors = size(traindesc,2);
trainingDescWords = zeros(1,numDescriptors);
for iter = 1:100
    for i = 1:numDescriptors
        descR = repmat(traindesc(:,i),1,K);
        d = sum((descR-clusters).^2);
        [~,trainingDescWords(i)] = min(d);
    end
    newClusters = zeros(128,K);
    for k = 1:K
        descs = traindesc(:,trainingDescWords == k);
        newClusters(:,k) = mean(descs,2);
    end
    df = sum((clusters - newClusters).^2);
    if mean(df) < 50
        break
    end
    clusters = newClusters;
end
bagOfWords = newClusters;
 
 
TrainIdx_ = zeros(1,trainim);
TrainIdx_Last = zeros(1,trainim);
t = 1;
for i = 1:trainim
    TrainIdx_Start(i) = t;
    TrainIdx_Last(i) = t + size(train_D{i},2) - 1;
    t = t + size(train_D{i},2);
end
 
testIdxStart = zeros(1,testim);
testIdxEnd = zeros(1,testim);
t = 1;
for i = 1:testim
    testIdxStart(i) = t;
    testIdxEnd(i) = t + size(test_D{i},2) - 1;
    t = t + size(test_D{i},2);
end

trainWords = cell(1,trainim);
for i = 1:trainim
    trainWords{i} = trainingDescWords(:,TrainIdx_Start(i):TrainIdx_Last(i));
end


test_ClassDescriptors = zeros(1,177634);
for i = 1:177634
    desc = testdesc(:,i);
    descR = repmat(desc,1,K);
    d = sum((descR-bagOfWords).^2);
    [~,test_ClassDescriptors(i)] = min(d);
end


testWords = cell(1,testim);
for i = 1:testim
    testWords{i} = test_ClassDescriptors(:,testIdxStart(i):testIdxEnd(i));
end
 
 
% Training 
 
trainingHist = zeros(trainim,K);
for i = 1:trainim
    counts = zeros(1,K);
    for k = 1:K
        counts(k) = sum(trainWords{i} == k);
    end
    trainingHist(i,:) = counts;
end
 
% Testing 
testHists = zeros(testim,K);
for i = 1:testim
    counts = zeros(1,K);
    for k = 1:K
        counts(k) = sum(testWords{i} == k);
    end
    testHists(i,:) = counts;
end
 

% SVM Training
tic 
SVM = cell(1,8);
for i = 1:8
    SVM{i} = fitcsvm(trainingHist,(train_gs == i)');
end
toc
scores = zeros(800,8);

tic
for i = 1:8
    [~,score] = predict(SVM{i}, testHists);
    scores(:,i) = score(:,2);
end
[~, predictions] = max(scores,[],2);
 toc

 % Calculate the accuracy

accuracy = sum(predictions == test_gs')/testim * 100


confmat = zeros(8,8);
for i = 1:testim
    correctclass = test_gs(i);
    predictedclass = predictions(i);
    confmat(correctclass, predictedclass) = ...
        confmat(correctclass, predictedclass) + 1;
end
confmat

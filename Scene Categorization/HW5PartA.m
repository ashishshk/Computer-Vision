load gs.mat;

% a = im2double(imread('hershey.jpg'));
% b = hist(a,20);
% imagesc(b);

% a = hist(train_gs,50);
% imagesc(a);

% cd test
% for i = 1:1888
%     a = im2double(imread(i+'.jpg'));
%     b(i,10) = hist(a);
% end

% testim = cell(1,800);
% trainim = cell(1,1888);

% Load the training and test data
path1 = 'train';
trainx = [];
trainy = [];
path2 = 'test';
testx = [];
testy = [];

% Specifying the paths for the training and test data
trainim = dir(fullfile(path1,'*.jpg')); % Wildcard used to list all the files with a .jpg extension.
testim = dir(fullfile(path2,'*.jpg'));

dataeltrain = numel(trainim);
for i = 1: dataeltrain
    index = strsplit(trainim(i).name,'.');
    index = str2num(index{1});
    trainy = [trainy, train_gs(index)];
    trainpath = fullfile(path1,trainim(i).name);
    im1 = im2double(imread(trainpath));
    
    % Getting the marginal histogram
    trainhist = getHist(im1,10);
    trainhist = trainhist(:);
    trainx = [trainx trainhist];
end

dataeltest = numel(testim);
for j = 1: dataeltest
    index = strsplit(testim(j).name,'.');
    index = str2num(index{1});
    testy = [testy, test_gs(index)];
    testpath = fullfile(path2,testim(j).name);
    im2 = imread(testpath);
    
    % Getting the marginal histogram
    testhist = getHist(im2,10);
    testhist = testhist(:);
    testx = [testx testhist];
end

predmat = [];
for k = 1:length(testx)
    test = testx(:,k);
    dist = pdist2(test', trainx');
    % distsort = sort(dist);
    [distance, index] = min(dist);
    [distance, index] = min(pdist2(test', trainx'));
     predmat = [predmat trainy(index)];
end

confmat = confusionmat(testy, predmat)
accuracy = trace(confmat)/sum(sum(confmat))*100

% Function for computing the color histogram of an image
function histogram = getHist(im,K)

histogram = [imhist(im(:,:,1),K), imhist(im(:,:,2),K), imhist(im(:,:,3),K)];

end


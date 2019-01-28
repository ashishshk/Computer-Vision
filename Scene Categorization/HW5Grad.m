cd matconvnet-1.0-beta25

% setup MatConvNet
run  matlab/vl_setupnn

% download a pre-trained CNN from the web (needed once)
% urlwrite(...
%   'http://www.vlfeat.org/matconvnet/models/imagenet-googlenet-dag.mat', ...
%   'imagenet-googlenet-dag.mat') ;

% load the pre-trained CNN
%For googlenet
net = dagnn.DagNN.loadobj(load('imagenet-googlenet-dag.mat')) ;
net.mode = 'test' ;

% load and preprocess an image

cd ..

%hist_train=single(zeros(1888,1000));
%Choose the layer for output
layernum=152;
net.vars(layernum).precious = true;

for i=1:1888

im=imread(strcat('train/',num2str(i),'.jpg'));
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;

% run the CNN
net.eval({'data', im_}) ;

% obtain the CNN otuput

scores = net.vars(layernum).value ;
scores = squeeze(gather(scores)) ;
 hist_train(i,:)=scores';
end
net.mode = 'test' ;

for i=1:800
im=imread(strcat('test/',num2str(i),'.jpg'));
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;

% run the CNN
net.eval({'data', im_}) ;

% obtain the CNN otuput
scores = net.vars(layernum).value ;
scores = squeeze(gather(scores)) ;
 hist_test(i,:)=scores';
end

load('gs.mat');
model = fitcecoc(hist_train,train_gs','Coding','onevsall');


predicted_label = predict(model,hist_test);
confmat = confusionmat(test_gs',predicted_label)


accuracy=trace(confmat)/(sum(sum(confmat)))*100


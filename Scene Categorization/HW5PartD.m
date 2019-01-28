% Install and compile MatConvNet (needed once).

cd matconvnet-1.0-beta25


%run <MatConvNet>/matlab/vl_setupnn

% % % run matlab/vl_compilenn ;

run matlab/vl_setupnn;


% Download a pre-trained CNN from the web (needed once).
urlwrite(...
   'http://www.vlfeat.org/matconvnet/models/imagenet-vgg-f.mat', ...
   'imagenet-vgg-f.mat') ;



% Setup MatConvNet.
%run matconvnet-1.0-beta25/matlab/vl_setupnn ;

% Load a model and upgrade it to MatConvNet current version.
net = load('imagenet-vgg-f.mat') ;
%net = load('fast-rcnn-vgg16-pascal07-dagnn.mat') ;

%net = vl_simplenn_tidy(net) ;
% 
cd ..

% % Obtain and preprocess an image.
hist_train=single(zeros(1888,1000));

for i=1:1888
  im=imread(strcat('train/',num2str(i),'.jpg'));
 inputimage = single(im) ;
 inputimage = imresize(inputimage, net.meta.normalization.imageSize(1:2)) ;
 inputimage = inputimage - net.meta.normalization.averageImage ;
% 
% % Run the CNN.
 res = vl_simplenn(net, inputimage) ;
% 
% % Show the classification result.
 scores = squeeze(gather(res(end-1).x)) ; 
 hist_train(i,:)=scores';
  
end

hist_train = normalize(hist_train,2);


hist_test=single(zeros(800,1000));

for i=1:800
  im=imread(strcat('test/',num2str(i),'.jpg'));
  inputimage = single(im) ; 
 inputimage = imresize(inputimage, net.meta.normalization.imageSize(1:2)) ;
 inputimage = inputimage - net.meta.normalization.averageImage ;
% 
% % Run the CNN.
 res = vl_simplenn(net, inputimage) ;
% 
% % Show the classification result.
 scores = squeeze(gather(res(end-1).x)) ;
 hist_test(i,:)=scores';
  
end

hist_test = normalize(hist_test,2);

load('gs.mat');

%Multi class discriminative classifier
model = fitcecoc(hist_train,train_gs','Coding','onevsall');

predictedlabels = predict(model,hist_test);

%Confusion matrix

confmat = confusionmat(test_gs',predictedlabels)

%Calculating classification accuracy

accuracy=trace(confmat)/(sum(sum(confmat)))*100







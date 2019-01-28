load cat_mask.mat

newIm = imread('dog.jpg');
size(newIm);

im = imresize(im,0.3);
im(im>=1) = 1
labels = imresize(labels,0.3);
labels = ~labels

im = round(im.*255);
[H W N] = size(im);
for i=1:3    
    tryim = newIm(70:70+H-1,70:70+W-1,i);
    sampleIm = im(:,:,i);
    tryim(tryim&labels) = sampleIm(tryim&labels);
    newIm(70:70+H-1,70:70+W-1,i) = tryim;
end;


figure();
imshow(newIm);

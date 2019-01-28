function runThis

N = 5;
% Load any image

im = im2double(rgb2gray(imread('Data/eagle.jpg')));

[G, L] = pyramidsGL(im, N);

% Display the Gaussian and Laplacian pyramid
  displayPyramids(G, L);
%   figure(3),
%   for i = 1:N
%       subplot(2,5,i),
%       if i == 3
%           title('Gaussian' , 'FontSize' , 16);
%       end
%       displayFFT(G{i});
%       subplot(2,5,i+5),
%       if i == 8
%           title('Laplacian' , 'FontSize' , 16);
%       end
%       title('Laplacian' , 'FontSize' , 16);
%       displayFFT(L{i});
%   end
  
  
  
 
end



function [G, L] = pyramidsGL(im, N)
% [G, L] = pyramidsGL(im, N)
% Creates Gaussian (G) and Laplacian (L) pyramids of 
%level N from image im.
% G and L are cell where G{i}, L{i} stores the i-th level of 
%Gaussian and Laplacian pyramid, respectively. 

cutoff_frequency = 7;

lowpass = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);

G{1} = im;

for i = 1 : N
    
    %Gaussian Pyramid
    
    smoothimage = imfilter(im,lowpass,'replicate');
    downsampled = imresize(smoothimage,0.5,'bilinear');
    G{i+1} = downsampled;
    im = downsampled;
    
    
    %Laplacian Pyramid
    
    
    if i == N
        
        L{i} = G{i};
    
    else
        
        upsampled = imresize(downsampled,size(G{i}));
        smoothimage2 = imfilter(upsampled,lowpass);
        L{i} = mat2gray(G{i} - smoothimage2);
        if i == 1
            L{i} = L{i}.*2;
        end
       %L{i} = mat2gray(A);
    
    end
end

% Reconstructing the original image from
% the Laplacian Pyramid

U = L{N};


for m = N:-1:1

ups = imresize(U,size(G{m}));
ups = imfilter(ups,lowpass);

U = L{m} + ups;
    
V = mat2gray(U);

end

% Displaying the original image
     figure(7);
     imshow(V);
     title('Sharpened Reconstructed Image' , 'FontSize' , 16);
     
% Displaying the error between the original image 
% and the reconstructed image
    error = immse(G{1},V)

end




function displayPyramids(G, L)
% Displays intensity and fft images of pyramids
  figure(5)
  
  for i = 1:5
  subplot(2,5,i); imshow(G{i});
  if(i==3)
      title('Gaussian Pyramid' , 'FontSize' , 16);
  end
  subplot(2,5,i+5); imshow(L{i});
  if i + 5 == 8
      title('Laplacian Pyramid' , 'FontSize' , 16);
  end

  end
end

function displayFFT(im)
% Displays FFT images
%im = G{1};
%imagesc(log(abs(fftshift(fft2(im)))),[minv maxv])
colormap(jet);
imagesc(log(abs(fftshift(fft2(im)))))

end



          


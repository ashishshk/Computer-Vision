function runThis

N = 5;
% Load any image

im = im2double(imread('Data/HW1_1_2_hybrid_image.jpg'));

[G, L] = pyramidsGL(im, N);

% Display the Gaussian and Laplacian pyramid
  displayPyramids(G, L);
%   figure(3),
%   for i = 1:N
%       subplot(2,5,i),
%       displayFFT(G{i});
%       subplot(2,5,i+5),
%       displayFFT(L{i});
%   end
  
  
  
 
end



function [G, L] = pyramidsGL(im, N)
% [G, L] = pyramidsGL(im, N)
% Creates Gaussian (G) and Laplacian (L) pyramids of 
%level N from image im.
% G and L are cell where G{i}, L{i} stores the i-th level of 
%Gaussian and Laplacian pyramid, respectively. 

cutoff_frequency = 2;

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
        %L{i} = mat2gray(A);
    
    end
end

% Reconstructing the original image from
% the Laplacian Pyramid

% U = L{N};
% 
% 
% for m = N:-1:1
% 
% ups = imresize(U,size(G{m}));
% ups = imfilter(ups,lowpass);
% 
% U = L{m} + ups;
%     
% V = mat2gray(U);
% 
% end
% 
% % Displaying the original image
%      figure(7);
%      imshow(V);
%      
% % Displaying the error between the original image 
% % and the reconstructed image
%      immse(G{1},V)

end




function displayPyramids(G, L)
% Displays intensity and fft images of pyramids
  figure(5)
  %title('Gaussian Pyramid');
  for i = 1:5
  subplot(2,5,i); imshow(G{i});
  if i == 3
      title('Gaussian Pyramid' , 'FontSize' , 16);
  end
  %subplot(2,5,2); imshow(G{2});
  %subplot(2,5,3); imshow(G{3});
  %subplot(2,5,4); imshow(G{4});
  %subplot(2,5,5); imshow(G{5});
  
  
 
  %title('Laplacian Pyramid');
  subplot(2 , 5 , i + 5); imshow(L{i});
  if i + 5 == 8
      title('Laplacian Pyramid' , 'FontSize' , 16);
  end
%   subplot(2,5,6); imshow(L{1});
%   subplot(2,5,7); imshow(L{2});
%   subplot(2,5,8); imshow(L{3});
%   subplot(2,5,9); imshow(L{4});
%   subplot(2,5,10);imshow(L{5});

  end
end

% function displayFFT(im)
% % Displays FFT images
% %im = G{1}
% %imagesc(log(abs(fftshift(fft2(im)))),[minv maxv])
% colormap(jet);
% imagesc(log(abs(fftshift(fft2(im)))))
% 
% end



          


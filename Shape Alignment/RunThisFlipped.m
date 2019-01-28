% function err_avg = evalAlignmentAll

clear; clf;
imgPath = 'data';

objList = {'apple', 'bat', 'bell', 'bird', 'Bone', 'bottle', 'brick', ...
    'butterfly', 'camel', 'car', 'carriage', 'cattle', 'cellular_phone', ...
    'chicken', 'children', 'device7', 'dog', 'elephant', 'face', 'fork', 'hammer', ...
    'Heart', 'horse', 'jar', 'turtle'};

numObj = length(objList);

err_align = zeros(numObj, 1);

figure(1);
ha = tight_subplot(5,5,[.01 .03],[.1 .01],[.01 .01]);
for i = 1 : numObj
    objName = objList{i};
    % Load image pair
    im1 = imread(fullfile(imgPath, [objName, '_1.png']));
    im2 = imread(fullfile(imgPath, [objName, '_2.png']));
    
    % Alignment
    tic;
	% You code this
    T = align_shape( im1, im2 );
    
    aligned = imtransform(im1, maketform('projective', double(T')), ...
        'XData',[1 size(im1,2)],'YData',[1 size(im1,1)]);
    toc
    
    % display alignment
    axes(ha(i));
    c = double(repmat(im1, [1 1 3]));
    c(:,:,2) = im2; c(:,:,3) = aligned;
    imshow(c);
    
    % Display errors
    err_align(i) = evalAlignment(im2, aligned);
    if err_align(i) > 8
        im11 = flip(im1,1);% horintal flip
        T1 = align_shape( im11, im2 );

        aligned1 = imtransform(im1, maketform('projective', double(T')), ...
            'XData',[1 size(im1,2)],'YData',[1 size(im1,1)]);
        toc
        err_align1(i) = evalAlignment(im2, aligned1);
        
            if err_align1(i) > 8 % verticle flip
                    im12 = flip(im2);
                    T2 = align_shape( im12, im2 );
                    aligned2 = imtransform(im1, maketform('projective', double(T')), ...
                        'XData',[1 size(im1,2)],'YData',[1 size(im1,1)]);
                    toc
                    err_align2(i) = evalAlignment(im2, aligned2);
            end
        [err_align(i),index] = min([err_align(i) err_align1(i) err_align2(i)]);    % chose the best align
    end

    fprintf('Error for aligning "%s": %f\n', objName, err_align(i));
end

% Export results
figure(2); bar(err_align);
set(gca, 'XTick', 1:numObj);
set(gca, 'XTickLabel', objList, 'FontSize', 12);
xlabel('Object', 'FontSize', 16);
ylabel('Alignment error', 'FontSize', 16);

fprintf('Averaged alignment error = %f\n', mean(err_align));
% end
clear;
clc;
close all; 

MAXSIZE  = 10; %CHANGE THIS FOR FILE NUMBERS
%postProcessedCarImages = cell(45576);
waveletImages = cell(MAXSIZE, 1);
originalImages = cell(MAXSIZE, 1);
area = 1;
tic
for k = 1:MAXSIZE
% Create a mat filename, and load it into a structure called matData.
    a = 1;
    b = 10;
    w = round(a + (b-a).*rand(1,1));
	photoFile = sprintf('Dataset/%d.jpg', k*w);
	if exist(photoFile, 'file')
		image = imread(photoFile);
        originalImages{area, 1} = image;
        
        %% Do wavelet LL
        imageGray = rgb2gray(image);
        [cA1,cH1,cV1,cD1] = dwt2(image,'coif4');
        postProc = uint8(cA1);
         %figure;
       %  imshow(imresize(image, 0.5));
         % ~imshow(postProc);
        %%Save to a .mat cell array
        waveletImages{area, 1} = postProc;
        area = area + 1;
%        if mod(k,100) == 0
%             thing = toc;
%             disp(k);
%             disp(94 * thing);
%             tic
%        end
	else
		fprintf('File %s does not exist.\n', matFileName);
    end
end
 save('waveletImages', 'waveletImages', '-v7.3');
 save('originalImages', 'originalImages', '-v7.3');
 toc
 %'-v7.3'
%%Save as mat file, and load in that way

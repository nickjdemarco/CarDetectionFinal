clear;
close all;
clc;

%% Load vehicle data set
data = load('fasterRCNNVehicleTrainingData.mat');
vehicleDataset = data.vehicleTrainingData;

%% Display first few rows of the data set.
vehicleDataset(1:4,:)

% %% Display One Example Image 
% % Add fullpath to the local vehicle data folder.
% dataDir = fullfile(toolboxdir('vision'),'visiondata');
% vehicleDataset.imageFilename = fullfile(dataDir, vehicleDataset.imageFilename);
% 
% % Read one of the images.
% I = imread(vehicleDataset.imageFilename{10});
% 
% % Insert the ROI labels.
% I = insertShape(I, 'Rectangle', vehicleDataset.vehicle{10});
% 
% % Resize and display image.
% I = imresize(I,3);
% figure
% imshow(I)

%% Split data into a training and test set.
idx = floor(0.6 * height(vehicleDataset));  % 60% of data for training
trainingData = vehicleDataset(1:idx,:);
testData = vehicleDataset(idx:end,:);

%% Create image input layer.
inputLayer = imageInputLayer([32 32 3]);                                   %SHOULD WE NORMALIZE DATA, SHOULD WE CHANGE INPUT LAYER
                                                                            %DOES IMAGE INPUT LAYER RESIZE INPUT, WHAT DOES THIS 32 32 ACTUALLY DO
%% Define the convolutional layer parameters.
filterSize = [3 3];
numFilters = 32;

%% Create the middle layers.
middleLayers = [
                
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)   
    reluLayer()
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)  
    reluLayer() 
    maxPooling2dLayer(3, 'Stride',2)    
    
    ];

%% Create the final layers
finalLayers = [
    
    % Add a fully connected layer with 64 output neurons. The output size
    % of this layer will be an array with a length of 64.
    fullyConnectedLayer(64)

    % Add a ReLU non-linearity.
    reluLayer()

    % Add the last fully connected layer. At this point, the network must
    % produce outputs that can be used to measure whether the input image
    % belongs to one of the object classes or background. This measurement
    % is made using the subsequent loss layers.
    fullyConnectedLayer(width(vehicleDataset))

    % Add the softmax loss layer and classification layer. 
    softmaxLayer()
    classificationLayer()
];

%% Combine layers
layers = [
    inputLayer
    middleLayers
    finalLayers
    ]

%% Training Options
% Options for step 1.
optionsStage1 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 256, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

% Options for step 2.
optionsStage2 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 128, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

% Options for step 3.
optionsStage3 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 256, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

% Options for step 4.
optionsStage4 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 128, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

options = [
    optionsStage1
    optionsStage2
    optionsStage3
    optionsStage4
    ];

%% Training
doTrainingAndEval = false;

if doTrainingAndEval
    % Set random seed to ensure example training reproducibility.
    rng(0);
    
    % Train Faster R-CNN detector. Select a BoxPyramidScale of 1.2 to allow
    % for finer resolution for multiscale object detection.
    detector = trainFasterRCNNObjectDetector(trainingData, layers, options, ...
        'NegativeOverlapRange', [0 0.3], ...
        'PositiveOverlapRange', [0.6 1], ...
        'BoxPyramidScale', 1.2);
else
    % Load pretrained detector for the example.
    detector = data.detector;
end

%% Test Image
% Read a test image.
%I = imread(testData.imageFilename{30});
%I = imread('2.jpg');
% I = cars;
load('waveletImages.mat');
load('originalImages.mat');
%for J = 1: length(testCellSmall)
for J = 1: 10
    
    waveletI = waveletImages{J};
    origI = originalImages{J};
    
    [m,n] = size(waveletI);
    n = n/3;
    origIResize = imresize(origI, [m n]);
    % Run the detector.
    tic
    [bboxes,scores] = detect(detector,waveletI);
    toc
    tic
    [bboxesOrig, scoresOrig] = detect(detector, origIResize);
    toc
    newScore = string(scores);
    newScoreOrig = string(scoresOrig);
    for P = 1 : length(scores)
        newScore(P) = "Car: " + num2str(round(scores(P)*100, 2))+ "%";
    end
    for P = 1 : length(scoresOrig)
        newScoreOrig(P) = "Car: " + num2str(round(scoresOrig(P)*100, 2))+ "%";
    end
    % Annotate detections in the image.
    if isempty(scores) == 0
        waveletI = insertObjectAnnotation(waveletI,'rectangle',bboxes,cellstr(newScore), 'FontSize', 20);
    end
    if isempty(scoresOrig) == 0
    origIResize = insertObjectAnnotation(origIResize, 'rectangle', bboxesOrig, cellstr(newScoreOrig), 'FontSize', 20);
    end
%     [m,n] = size(I);
%     n = n/3;
%     origImageRe = imresize(orig, [m n]);

final = [origIResize;waveletI];
figure;
imshow(final);
title("Original vs. Wavelet Preprocessing");

%% OR
% figure;
% imshow(I);
% figure;
% imshow(testImageRe);
end

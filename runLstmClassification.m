% figure
% plot(XTrain{101}')
% grid on
% xlabel("Time Step")
% title("Training Observation 1")
% numFeatures = size(XTrain{1},1);
% legend("Feature " + string(1:numFeatures),'Location','northeastoutside')

%% 
inputSize = size(XTrain{1},1);
numClasses = numel(categories(YTrain));

numHiddenUnits = 50;
maxEpochs = 50;
miniBatchSize = 100;

%% layers
summary(YTrain)

weigths = 1e2 ./ countcats(YTrain)'
weigths = [0.3 1 1 1 1];
layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    weightedClassificationLayer(weigths)];


% alpha = 0.25;
% gamma = 5;
% layers = [ ...
%     sequenceInputLayer(inputSize)
%     lstmLayer(numHiddenUnits,'OutputMode','last')
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     FLClassificationLayer(alpha,gamma)];


% layers = [ ...
%     sequenceInputLayer(inputSize)
%     lstmLayer(numHiddenUnits,'OutputMode','last')
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     classificationLayer];

%%
options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','every-epoch', ...                %%%%%%%%
    'Verbose',0, ...
    'Plots','training-progress');

net = trainNetwork(XTrain,YTrain,layers,options);

%% test
YPred = classify(net,XTest, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');
figure;confusionchart(YTest,YPred, ...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');
title('testing set')


%% check over-fitting
YPred = classify(net,XTrain, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');
figure;confusionchart(YTrain,YPred, ...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');
title('training set')


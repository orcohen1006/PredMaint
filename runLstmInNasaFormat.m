%% remove errors col's is necessary 

TrainSet = TrainSet(:,[1:2 4:7 13]);
TestSet = TestSet(:,[1:2 4:7 13]);

%%% seq2seq
% Prepare Training Data
% Load the data using the function preprocessDataTrain shown at the end of this example. The function prepareDataTrain extracts the data from filenamePredictors and returns the cell arrays XTrain and YTrain, which contain the training predictor and response sequences.
[XTrain,YTrain] = prepareDataTrain(TrainSet);
% Remove Features with Constant Values
% Features that remain constant for all time steps can negatively impact the training. Find the rows of data that have the same minimum and maximum values, and remove the rows.
m = min([XTrain{:}],[],2);
M = max([XTrain{:}],[],2);
idxConstant = M == m;


for i = 1:numel(XTrain)
    XTrain{i}(idxConstant,:) = [];
end
% Normalize Training Predictors
% Normalize the training predictors to have zero mean and unit variance. To calculate the mean and standard deviation over all observations, concatenate the sequence data horizontally.
mu = mean([XTrain{:}],2);
sig = std([XTrain{:}],0,2);

for i = 1:numel(XTrain)
    XTrain{i} = (XTrain{i} - mu) ./ sig;
end
% Clip Responses
% To learn more from the sequence data when the engines are close to failing, clip the responses at the threshold 150. This makes the network treat instances with higher RUL values as equal.
thr = 240;
for i = 1:numel(YTrain)
    YTrain{i}(YTrain{i} > thr) = thr;
end
% This figure shows the first observation and the corresponding clipped response.
    
% Prepare Data for Padding
% To minimize the amount of padding added to the mini-batches, sort the training data by sequence length. Then, choose a mini-batch size which divides the training data evenly and reduces the amount of padding in the mini-batches.
% Sort the training data by sequence length.
for i=1:numel(XTrain)
    sequence = XTrain{i};
    sequenceLengths(i) = size(sequence,2);
end
%{
[sequenceLengths,idx] = sort(sequenceLengths,'descend');
XTrain = XTrain(idx);
YTrain = YTrain(idx);
% View the sorted sequence lengths in a bar chart.
figure
bar(sequenceLengths)
xlabel("Sequence")
ylabel("Length")
title("Sorted Data")
% Choose a mini-batch size which divides the training data evenly and reduces the amount of padding in the mini-batches. Specify a mini-batch size of 20. This figure illustrates the padding added to the unsorted and sorted sequences.
%}
miniBatchSize = 5;

% Define Network Architecture
% Define the network architecture. Create an LSTM network that consists of an LSTM layer with 200 hidden units, followed by a fully connected layer of size 50 and a dropout layer with dropout probability 0.5.
numResponses = size(YTrain{1},1);
featureDimension = size(XTrain{1},1);
numHiddenUnits = 4;

layers = [ ...
    sequenceInputLayer(featureDimension)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(50)
    dropoutLayer(0.5)
    fullyConnectedLayer(numResponses)
    regressionLayer];
% layer_graph = layerGraph(layers);
% figure; plot(layer_graph);
% Specify the training options. Train for 60 epochs with mini-batches of size 20 using the solver 'adam'. Specify the learning rate 0.01. To prevent the gradients from exploding, set the gradient threshold to 1. To keep the sequences sorted by length, set 'Shuffle' to 'never'.
maxEpochs = 30;

% remove empties: 
idx = find(~cellfun(@isempty,XTrain));
XTrain = XTrain(idx);
YTrain = YTrain(idx);
idxValid = randperm(size(XTrain,1),round(0.1 * size(XTrain,1)));
XValid = XTrain(idxValid);
YValid = YTrain(idxValid);

options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Shuffle','never', ...
    'Plots','training-progress',...
    'Verbose',0,...
    'ValidationData',{XValid,YValid});

% Train the Network
% Train the network using trainNetwork.
net = trainNetwork(XTrain,YTrain,layers,options);

% Test the Network
% Prepare the test data using the function prepareDataTest shown at the end of the example. The function prepareDataTest extracts the data from filenamePredictors and filenameResponses and returns the cell arrays XTest and YTest, which contain the test predictor and response sequences, respectively.

[XTest,YTest] = prepareDataTest(TestSet);
idx = find(~cellfun(@isempty,XTest));
XTest = XTest(idx);
YTest = YTest(idx);
% Remove features with constant values using idxConstant calculated from the training data. Normalize the test predictors using the same parameters as in the training data. Clip the test responses at the same threshold used for the training data.
for i = 1:numel(XTest)
    XTest{i}(idxConstant,:) = [];
    XTest{i} = (XTest{i} - mu) ./ sig;
    YTest{i}(YTest{i} > thr) = thr;
end
%Make predictions on the test data using predict.
%To prevent the function from adding padding to the data, specify the mini-batch size 1. 
YPred = predict(net,XTest,'MiniBatchSize',1);
%The LSTM network makes predictions on the partial
%sequence one time step at a time. At each time step, 
%the network predicts using the value at this time step, and the network state calculated from the previous time steps only. The network updates its state between each prediction. The predict function returns a sequence of these predictions. The last element of the prediction corresponds to the predicted RUL for the partial sequence.
%Alternatively, you can make predictions one time step 
%at a time by using predictAndUpdateState. This is useful
%when you have the values of the time steps arriving in a stream.
%Usually, it is faster to make predictions on full sequences when 
%compared to making predictions one time step at a time
%. For an example showing how to forecast future time steps
%by updating the network between single time step predictions,
%see Time Series Forecasting Using Deep Learning. 
%Visualize some of the predictions in a plot.
idx = randperm(numel(YPred),16);
figure
for i = 1:numel(idx)
    subplot(4,4,i)
    xtmp = XTest{idx(i)};
    plot(YTest{idx(i)},'--')
    hold on
    plot(YPred{idx(i)},'.-')
    hold off
    
    %ylim([0 thr + 25])
    title("Test Observation " + idx(i))
    xlabel("Time Step")
    ylabel("RUL")
end
legend(["Test Data" "Predicted"],'Location','southeast')
%For a given partial sequence, the predicted current RUL is the last element of the predicted sequences. Calculate the root-mean-square error (RMSE) of the predictions, and visualize the prediction error in a histogram. 
for i = 1:numel(YTest)
    YTestLast(i) = YTest{i}(end);
    YPredLast(i) = YPred{i}(end);
end
outliersK = 24* 5;
outliers = abs(YPredLast- YTestLast) > outliersK;
numOfoutilrs = sum(outliers)/numel(outliers);
YPredLast = YPredLast(~outliers);
YTestLast = YTestLast(~outliers);
figure
rmse = sqrt(mean((YPredLast - YTestLast).^2));
histogram(YPredLast - YTestLast);
title("RMSE = " + rmse + "   outliers: " + numOfoutilrs * 100 + "%");
ylabel("Frequency");
xlabel("Error");

% Example Functions
% The function prepareDataTrain extracts the data from filenamePredictors and returns the cell arrays XTrain and YTrain which contain the training predictor and response sequences, respectively.
% The data contains zip-compressed text files with 26 columns of numbers, separated by spaces. Each row is a snapshot of data taken during a single operational cycle, and each column is a different variable. The columns correspond to the following:
% 1: Unit number
% 2: Time in cycles
% 3–5: Operational settings
% 6–26: Sensor measurements 1–17
function [XTrain,YTrain] = prepareDataTrain(dataTable)
%dataTable.machineID=[];
errorsCols = ~cellfun(@(x) contains(x,'error'),dataTable.Properties.VariableNames);
%dataTable = dataTable(:,errorsCols);
data = table2array(dataTable);

numObservations = max(data(:,1));

XTrain = cell(numObservations,1);
YTrain = cell(numObservations,1);
for i = 1:numObservations
    idx = data(:,1) == i;
    
    X = data(idx,3:end)';
    XTrain{i} = X;
    
    timeSteps = data(idx,2)';
    Y = fliplr(timeSteps);
    YTrain{i} = Y;
end

for i = 1:numel(XTrain)
   tmp =  XTrain{i};
   numofdays = randi([7 21],1);
   cutSize = min(24*numofdays,size(tmp,2));
   XTrain{i}  =tmp(:,size(tmp,2)-cutSize+1:size(tmp,2));
   YTrain{i} = YTrain{i}(size(tmp,2)-cutSize+1:end);
end
end

% The function prepareDataTest extracts the data from filenamePredictors and filenameResponses and returns the cell arrays XTest and YTest, which contain the test predictor and response sequences. In filenamePredictors, the time series ends some time prior to system failure. The data in filenameResponses provides a vector of true RUL values for the test data.
function [XTest,YTest] = prepareDataTest(TestSet)

[XTest,YTest] = prepareDataTrain(TestSet);


end









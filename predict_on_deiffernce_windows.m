%% prepareDate 
clc;clear all;
% defines
failureSizes = [4:4:120];
sample_first = 24;
sample_rate = 3;
telemetryWindowSizesVec = 24;
errorWindowSize = 24;

% categories labels 
ct = {'None' ,'comp1' , 'comp2' ,'comp3','comp4'};
rNames = arrayfun(@(x) ['p_wind_' num2str(x)],failureSizes,'UniformOutput',0);
% for collect results
acc =  zeros(size(failureSizes));
recallMat = zeros([numel(failureSizes),5]);
recallTable =  table('Size',[numel(failureSizes),5],'VariableTypes',{'double','double','double','double','double'},'VariableNames',ct,'RowNames',rNames);
% training parameters
costTable = [0 1 1 1 1; 100 0 1 1 1;100 1 0 1 1; 100 1 1 0 1; 100 1 1 1 0];

for f_index =1 :numel(failureSizes)
failureWindowSize = failureSizes(f_index);
% prepare and split data
[TrainingSet,TestingSet] = PrepareTrainingAndTestingSets(sample_first,sample_rate, telemetryWindowSizesVec, errorWindowSize, failureWindowSize);
% training
[trainedClassifier, validationAccuracyMincost] = trainClassifierBoostingTrees(TrainingSet,costTable);
% testing

TestingData = TestingSet(:,1:end-1);
groundTrue =  TestingSet(:,end);
if istable(groundTrue)
    groundTrue = table2array(groundTrue);
end
yfit = trainedClassifier.predictFcn(TestingData);

f =figure ; ch= confusionchart(groundTrue,yfit, 'ColumnSummary','column-normalized','RowSummary','row-normalized');
title(['failures predict on ' num2str(failureWindowSize) ' hours']);
savefig(f,['\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFailuresWindows\confChart' num2str(failureWindowSize) '_hours.fig'],'compact');

%
[m,order] = confusionmat(groundTrue,yfit);
recallVec =  diag(m)./sum(m,2);
precisionVec =  diag(m)./sum(m,1)';
%save relevant Data 
close
save(['\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFailuresWindows\fail' num2str(failureSizes(f_index)) '.mat'],'validationAccuracyMincost','m','order','recallVec','precisionVec');

acc(f_index) = validationAccuracyMincost;
recallMat(f_index,:) = reshape(recallVec,1,5);
end

save(['\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFailuresWindows\totalRes.mat'],'acc','recallMat');

try
f =figure; plot(failureSizes,acc);
xlabel 'failure predict [hours]';
ylabel 'validation Accuracy [%]';
title 'Accuracy vs time to failure predict ';
savefig(f, '\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFailuresWindows\failureGraph.fig');
catch
end
try
f =figure; plot(failureSizes,recallMat);
xlabel 'failure predict [hours]';
ylabel 'recall [%]';
title 'recall vs time to failure predict ';
legend(cellstr(order),'interpreter','none');
savefig(f, '\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFailuresWindows\recallPlot.fig');
catch
end
try
recallTable.Variables = recallMat(:,[1:3 5 4]);
f =figure; 
stackedplot(recallTable);
xticklabels = recallTable.Properties.RowNames;
xlabel 'failure predict [hours]';
title 'recall vs time to failure predict ';
savefig(f, '\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFailuresWindows\recallStackedPlot.fig');
catch
end
%%  repeat with tele and error same to failures

return
% defines
failureSizes = 1:120;
sample_first = 24;
sample_rate = 3;

% for looping
acc =  zeros(size(failureSizes));
% training parameters
costTable = [0 1 1 1 1; 100 0 1 1 1;100 1 0 1 1; 100 1 1 0 1; 100 1 1 1 0];

for f_index =1 :numel(failureSizes)
failureWindowSize = failureSizes(f_index);
telemetryWindowSizesVec = failureWindowSize;
errorWindowSize = failureWindowSize;
% prepare and split data
[TrainingSet,TestingSet] = PrepareTrainingAndTestingSets(sample_first,sample_rate, telemetryWindowSizesVec, errorWindowSize, failureWindowSize);
% training
[trainedClassifier, validationAccuracy] = trainClassifierBoostingTrees(TrainingSet,costTable);
% testing

TestingData = TestingSet(:,1:end-1);
groundTrue =  TestingSet(:,end);
groundTrue = table2array(groundTrue);
yfit = trainedClassifier.predictFcn(TestingData);

fig = figure; confusionchart(groundTrue,yfit, 'ColumnSummary','column-normalized','RowSummary','row-normalized');
title(['failures predict on ' num2str(failureWindowSize) ' hours']);
savefig(fig,['\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFilureWindoesSameTime\confChart' num2str(failureWindowSize) '_hours.fig'],'compact');
%save relevant Data 
close
save(['\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFilureWindoesSameTime\fail' num2str(failureSizes(f_index)) '.mat'],'validationAccuracy');
end


try
f =figure; plot(failureSizes,acc);
xlabel 'failure predict [hours]';
ylabel 'validation Accuracy [%]';
title 'Accuracy vs time to failure predict ';
savefig(f, ['\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\trainedModels\compareFilureWindoesSameTime\failureGraphSameTimes.fig']);
catch
end

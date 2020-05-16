clear; close all;

sample_first = 1; % start time with relevant history
sample_rate = 3;  % grid space

load('..\data\dataTables.mat');
MACHINE_NUM = 100;
%% get dates frame
teles = telemetry(telemetry.machineID == 1,:);
datesFrame = [teles.datetime(1) teles.datetime(end)];
%% get errors features for all machines
ErrorsFeatures = cell(1,MACHINE_NUM);
for i=1:MACHINE_NUM
    curID = i;
    errs_curID = errors(errors.machineID == curID,:);
    windowSize = 24;
    normailizeByWindowSize = false;
    errors_feature = ...
        GetErrorsFeature(errs_curID, datesFrame,windowSize, normailizeByWindowSize, sample_first,sample_rate);
    ErrorsFeatures{i} = errors_feature;
end
%% run over all failures and create a table
FailuresErrors = timetable;
for i=1:height(failures) % overall num of failures
    curFailure = failures(i,:);
    currentErrorsFeature = ErrorsFeatures{curFailure.machineID};
    curTime = curFailure.datetime;
    relevantRowLogical = currentErrorsFeature.datetime == curTime;
    sumPerError = currentErrorsFeature(relevantRowLogical,:);
    sumErrors = sum(table2array(timetable2table(sumPerError(:,1:end),'ConvertRowTimes',false)));
    sumErrors = timetable(sumPerError.datetime,sumErrors,'VariableNames',{'sumErrors'});
    FailuresErrors = [FailuresErrors; curFailure sumPerError sumErrors];
end
FailuresErrors.failure = categorical(FailuresErrors.failure);

%% histograms
f = figure;histogram(FailuresErrors.sumErrors);
title(['histogram' newline 'number of errors ' num2str(windowSize) ' hours before failure']);
numOfComps = 4;
numOfErrors = 5;
H = cell(numOfComps,numOfErrors); % cell matrix of histograms
Hfigs = [f]; % figures of histograms
comps = categories(FailuresErrors.failure);
f = figure;
for compNum = 1:numOfComps
    curCompTable = FailuresErrors(FailuresErrors.failure == comps(compNum),:);
    for errNum = 1:numOfErrors
        %f = figure;
        subplot(numOfComps,numOfErrors,(compNum-1)*numOfErrors + errNum)
        X = curCompTable(:,errNum + 2); % 2 first columns arenot interesting
       % H{compNum,errNum} = 
       histogram(X.Variables);
%         title(['histogram' newline 'number of error' num2str(errNum) newline...
%             num2str(windowSize) ' hours before failure in comp' num2str(compNum) newline...
%             'there are ' num2str(height(curCompTable)) ' of this failure type']);
       % h = histogram(X.Variables);
       if errNum == 1
           ylabel(['comp: ' num2str(compNum)]);
       end
       if compNum == numOfComps
           xlabel(['error: ' num2str(errNum)]);
       end
       if compNum == 1
           title([num2str(windowSize) 'hours before failure']);
       end
        grid on;
     %   Hfigs = [Hfigs f];
    end
end

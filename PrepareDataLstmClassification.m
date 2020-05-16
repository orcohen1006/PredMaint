clear; close all;
load('..\data\dataTables.mat');

MACHINE_NUM = 100;
scenario_counter = 0;
sample_first = 1; % start time with relevant history
sample_rate = 1;  % grid space
moveMeanParam = 6;
hoursToDivideBy = 24;
failures.failure = categorical(failures.failure);
X = [];
Y = [];
for curID=1:MACHINE_NUM
    
    teles_curID = telemetry(telemetry.machineID == curID,:);
    failures_curID = failures(failures.machineID == curID,:);
    maints_curID = maint(maint.machineID == curID,:);
    if (isempty(failures_curID)) 
        continue;
    end
    %% prepare telemetry
    teles_feature = teles_curID;
    teles_feature.machineID = [];
    teles_feature = varfun(@(x) smoothdata(x,'movmean',moveMeanParam),teles_feature);
    teles_feature = varfun(@normalize,teles_feature);
    datesFrame = [teles_curID.datetime(1) teles_curID.datetime(end)];    
    Features = teles_feature;
    %% prepare maintenance
    maints_feature = GetMaintFeature(maints_curID, datesFrame, sample_first,sample_rate);
    maints_feature = varfun(@normalizeMaint,maints_feature);
    Features = synchronize(teles_feature, maints_feature);
    %%     
    Features = table2array(Features);
    numOfSamples = size(Features,1);
    reminder = mod(numOfSamples,hoursToDivideBy);
    Features(end-reminder+1:end,:) = []; % get rid of last samples
    numOfSamples = size(Features,1);
    rowDist = hoursToDivideBy * ones(1, numOfSamples / hoursToDivideBy);
    X_curId = mat2cell(Features,rowDist);
    X_curId = cellfun(@(x) transpose(x),X_curId,'UniformOutput',false); % to match example
    Y_curId = labelByFailures(failures_curID,datesFrame,hoursToDivideBy,numOfSamples);
%% 
    X = [X ; X_curId];
    Y = [Y ; Y_curId];
end

%% devide to train and test
pivot = ceil(size(X,1) / 2);
XTrain = X(1:pivot);
YTrain = Y(1:pivot);
XTest = X(pivot+1:end);
YTest = Y(pivot+1:end);
%% throw away some 'none's to make the training data balanced

% prcnOfRemainingNones = 0.91;
% noneIds = find(YTrain == 'none');
% numOfNotNones = length(YTrain) - length(noneIds);
% numOfRemainingNones = round((prcnOfRemainingNones*numOfNotNones)/(1-prcnOfRemainingNones));
% tmp = randperm(length(noneIds),length(noneIds)-numOfRemainingNones);
% idsToThrow = noneIds(tmp);
% XTrain(idsToThrow) = [];
% YTrain(idsToThrow) = [];
% 
% %% throw away some 'none's to make the testing data balanced
% 
% noneIds = find(YTest == 'none');
% numOfNotNones = length(YTest) - length(noneIds);
% numOfRemainingNones = round((prcnOfRemainingNones*numOfNotNones)/(1-prcnOfRemainingNones));
% tmp = randperm(length(noneIds),length(noneIds)-numOfRemainingNones);
% idsToThrow = noneIds(tmp);
% XTest(idsToThrow) = [];
% YTest(idsToThrow) = [];
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ----- diffrent way to split data -----
% numOfClasses = 5;
% train_test_ratio = 2/3;
% pivot = ceil(size(X,1)* train_test_ratio);
% XTrain = X(1:pivot);
% YTrain = Y(1:pivot);
% XTest = X(pivot+1:end);
% YTest = Y(pivot+1:end);
% prcnOfRemainingNones = 0.70;
% 
% [XTrain,YTrain] = tryingToBalance(XTrain,YTrain,numOfClasses,prcnOfRemainingNones);
% [XTest,YTest] = tryingToBalance(XTest,YTest,numOfClasses,prcnOfRemainingNones);
% 


% ----- ----- ----- ----- -----  -------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function y = normalize(x)
    y = x - mean(x);
    sig = std(x);
    y = y./ sig;
end
function Y = labelByFailures(failures_curID,datesFrame,hoursToDivideBy,numOfSamples)
    K=[];
    Y = cell(numOfSamples / hoursToDivideBy, 1);
    Y = cellfun(@(y) ('none'),Y,'UniformOutput',false);
    Y = categorical(Y);
    firstDate = datesFrame(1);
    for i=1:height(failures_curID)
        hoursPassed = hours(failures_curID.datetime(i) - firstDate);
        index = ceil(hoursPassed/hoursToDivideBy);
        K = [K index];
        Y(index) = failures_curID.failure(i);
        if(index > 1)
            Y(index-1) = failures_curID.failure(i);
        end
        %%
    end
end
%%
function y = normalizeMaint(x)
    maxDays = 16;
    maxHours = maxDays * 24;
    y = x ./ maxHours;
    y(y>1) = 1;
%     y = 5*y;
end

%%
function [X,Y] = tryingToBalance(X,Y,numOfClasses,prcnOfRemainingNones)
    ind_classes = cell(1,numOfClasses);
    for n = 1:numOfClasses-1
        ind_classes{n} = find(Y == ['comp' num2str(n)]);
    end
    ind_classes{end} = find(Y == 'none');
    n_eachClass = cellfun(@length,ind_classes);
    maxPerCompClass = min(n_eachClass(1:4));
    n_remainingNones = round(prcnOfRemainingNones * maxPerCompClass*(numOfClasses-1) / (1-prcnOfRemainingNones));
    remainingIndexes = [];
    for n = 1:numOfClasses-1
        cur_indexes = ind_classes{n};
        tmp = randperm(length(cur_indexes),maxPerCompClass);
        remainingIndexes = [remainingIndexes; cur_indexes(tmp)];
    end
    none_indexes = ind_classes{numOfClasses};
    tmp = randperm(length(none_indexes),n_remainingNones);
    remainingIndexes = [remainingIndexes; none_indexes(tmp)];
    Y = Y(remainingIndexes);
    X = X(remainingIndexes);
    %% shuffle...
    ind_perm = randperm(length(Y));
    Y = Y(ind_perm);
    X = X(ind_perm);

end


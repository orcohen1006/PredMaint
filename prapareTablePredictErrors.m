%% 
clear; close all;

sample_first = 24; % start time with relevant history
sample_rate = 3;  % grid space

load('\\hmhfiler\acustica1\ALGOR\Or\PredictiveMaintenance\data\dataTables.mat');
MACHINE_NUM = 100;
Feature=[];

errWindows = 24 ;
failWindows = errWindows +48;

for i=1:MACHINE_NUM
    curID = i;
   
    teles_curID = telemetry(telemetry.machineID == curID,:);
    errs_curID = errors(errors.machineID == curID,:);
    failures_curID = failures(failures.machineID == curID,:);
    maints_curID = maint(maint.machineID == curID,:);
    machines_curID = machines(machines.machineID == curID, :);

    datesFrame = [teles_curID.datetime(1) teles_curID.datetime(end)];

    teles_feature = GetTelemetryFeature(teles_curID, [24], sample_first,sample_rate);
    
    %teles_freq = getTeleFFT(teles_curID, [24], sample_first,sample_rate);
    
    %errors_feature = GetErrorsFeature(errs_curID, datesFrame,24, false, sample_first,sample_rate);
    maints_feature = GetMaintFeature(maints_curID, datesFrame, sample_first,sample_rate);
    machines_feature = GetMachineFeature(machines_curID, datesFrame, sample_first,sample_rate);
   % failures_labaling = GetFailuresLabeling(failures_curID, datesFrame, 48, sample_first,sample_rate);     
    failures_labaling =  CategoricalLabeling(failures_curID, datesFrame, failWindows, sample_first, sample_rate);
    errorsLabeled = CategoricalErrors(errs_curID, datesFrame,errWindows, sample_first,sample_rate);
    
   % Feature = [Feature; teles_feature teles_freq maints_feature machines_feature errorsLabeled];
    Feature = [Feature; teles_feature maints_feature machines_feature failures_labaling errorsLabeled];


%% 
end

% % trying balancing data
%Feature =Feature(Feature.errors ~='None',:);
Feature.errors(Feature.failure == 'None') = 'None';
%Feature.errors(Feature.failures_labaling ~='None')= 'error1_24'
%% split to training sets
pivotDate = datetime(2015,7,31,1,00,0);
TrainingSet = timetable2table(Feature(Feature.datetime < pivotDate,:));
TrainingSet.datetime = []; TrainingSet.machineID = [];

TestingSet = timetable2table(Feature(Feature.datetime > pivotDate + hours(24),:));
TestingSet.datetime = []; TestingSet.machineID = [];

%% 
costTable = [0 1 1 1 1 1; 50 0 1 1 1 1;50 1 0 1 1 1; 50 1 1 0 1 1; 50 1 1 1 0 1; 50 1 1 1 1 0];

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

%% 
clear; close all;

sample_first = 24; % start time with relevant history
sample_rate = 3;  % grid space

load('..\data\dataTables.mat');
MACHINE_NUM = 100;
Feature=[];

for i=1:MACHINE_NUM
    curID = i;
   
    teles_curID = telemetry(telemetry.machineID == curID,:);
    errs_curID = errors(errors.machineID == curID,:);
    failures_curID = failures(failures.machineID == curID,:);
    maints_curID = maint(maint.machineID == curID,:);
    machines_curID = machines(machines.machineID == curID, :);

    datesFrame = [teles_curID.datetime(1) teles_curID.datetime(end)];

    teles_feature = GetTelemetryFeature(teles_curID, [6,12,24,48], sample_first,sample_rate);
    errors_feature = GetErrorsFeature(errs_curID, datesFrame,24, false, sample_first,sample_rate);
    maints_feature = GetMaintFeature(maints_curID, datesFrame, sample_first,sample_rate);
    machines_feature = GetMachineFeature(machines_curID, datesFrame, sample_first,sample_rate);
%     failures_labaling = GetFailuresLabeling(failures_curID, datesFrame, 24, sample_first,sample_rate);     
    failures_labaling =  CategoricalLabeling(failures_curID, datesFrame, [24], sample_first, sample_rate);
    Feature = [Feature; teles_feature errors_feature maints_feature machines_feature failures_labaling];

    % dot freq processing
   %teles_freq = getFreqFeature(teles_curID, sample_first, sample_rate);

%% 
end

%Feature =Feature(Feature.failure ~='None',:);
Feature.error1_over_24hrs=[];
Feature.error2_over_24hrs=[];
Feature.error3_over_24hrs=[];
Feature.error4_over_24hrs=[];
Feature.error5_over_24hrs=[];
%% split to training sets
pivotDate = datetime(2015,7,31,1,00,0);
TrainingSet = timetable2table(Feature(Feature.datetime < pivotDate,:));
TrainingSet.datetime = []; TrainingSet.machineID = [];

TestingSet = timetable2table(Feature(Feature.datetime > pivotDate + hours(24),:));
TestingSet.datetime = []; TestingSet.machineID = [];

%% 

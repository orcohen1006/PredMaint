clear; close all;
load('..\data\dataTables.mat');
sample_first = 24; % start time with relevant history
sample_rate = 3;  % grid space
curID = 1;

teles_curID = telemetry(telemetry.machineID == curID,:);
errs_curID = errors(errors.machineID == curID,:);
failures_curID = failures(failures.machineID == curID,:);
maints_curID = maint(maint.machineID == curID,:);
machines_curID = machines(machines.machineID == curID, :);

datesFrame = [teles_curID.datetime(1) teles_curID.datetime(end)];

categoricalLabeling = ...
    CategoricalLabeling(failures_curID, datesFrame, [24 48 72 240], sample_first, sample_rate);
function [TelemetryFeatures] = GetTelemetryFeature_OLD(teles_curID)

% smallWindow = 3;
% bigWindow = 24;
%INDEXES = [24:3:size(telemetry,1)-24];
%% mean 3 samples

fun = @(x) movmean(x,[2 0]);
teleMean3 = varfun(fun,teles_curID(:,2:end));
teleMean3.Properties.VariableNames = {'voltmean', 'rotatemean', 'pressuremean', 'vibrationmean'};
%teleMean3 = teleMean3(INDEXES,:);

%% std 3 samples
fun = @(x) movstd(x,[2 0]);
teleStd3 = varfun(fun,teles_curID(:,2:end));
teleStd3.Properties.VariableNames = {'voltsd', 'rotatesd', 'pressuresd', 'vibrationsd'};

%% mean 24
fun = @(x) movmean(x,[23 0]);
teleMean24 = varfun(fun,teles_curID(:,2:end));
teleMean24.Properties.VariableNames = {'voltmean_24hrs', 'rotatemean_24hrs', 'pressuremean_24hrs', 'vibrationmean_24hrs'};

%% std 24 samples
fun = @(x) movstd(x,[23 0]);
teleStd24 = varfun(fun,teles_curID(:,2:end));
teleStd24.Properties.VariableNames = {'voltsd_24hrs' ,'rotatesd_24hrs', 'pressuresd_24hrs', 'vibrationsd_24hrs'};

%% 
TelemetryFeatures = [teles_curID(:,1) teleMean3 teleStd3 teleMean24 teleStd24];
TelemetryFeatures = TelemetryFeatures([24:3:end],:);

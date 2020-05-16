function [TelemetryFeatures] = GetTelemetryFeature(teles_curID, windowsSizesVec,sample_first,sample_rate)

TelemetryFeatures = teles_curID(:,1); %% only machineID column
%%
for i = 1:length(windowsSizesVec)
    windowSize = windowsSizesVec(i);
    %% moving mean
    fun = @(x) movmean(x,[windowSize-1 0]);
    teleMean = varfun(fun,teles_curID(:,2:end));
    teleMean.Properties.VariableNames = ...
        {['voltmean_' num2str(windowSize) 'hrs'], ['rotatemean_' num2str(windowSize) 'hrs'],...
        ['pressuremean_' num2str(windowSize) 'hrs'], ['vibrationmean_' num2str(windowSize) 'hrs']};
    %% moving std
    fun = @(x) movstd(x,[windowSize-1 0]);
    teleStd = varfun(fun,teles_curID(:,2:end));
    teleStd.Properties.VariableNames = ...
        {['voltstd_' num2str(windowSize) 'hrs'], ['rotatestd_' num2str(windowSize) 'hrs'],...
        ['pressurestd_' num2str(windowSize) 'hrs'], ['vibrationstd_' num2str(windowSize) 'hrs']};

    %%  
    TelemetryFeatures = [TelemetryFeatures teleMean teleStd];
end
%% sample telemetry in sample_window

% startRow = max(windowsSizesVec) ?? 

TelemetryFeatures = TelemetryFeatures(sample_first:sample_rate:end , :);




end


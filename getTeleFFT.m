function [teleFreqDomain] = getTeleFFT(teles_curID, windowsSizesVec,sample_first,sample_rate)

teleFreqDomain = [];
%%
for i = 1:length(windowsSizesVec)
    %% moving mean
    fun = @(x) fft(x);
    teleFFT = varfun(fun,teles_curID(:,2:end));
    teleFFT.Properties.VariableNames = ...
        {['voltmean_fft'], ['rotatemean_fft'],...
        ['pressuremean_fft'], ['vibrationmean_fft']};
  
    %%  
    teleFreqDomain = [teleFreqDomain teleFFT];
end
%% sample telemetry in sample_window

% startRow = max(windowsSizesVec) ?? 

teleFreqDomain = teleFreqDomain(sample_first:sample_rate:end , :);




end


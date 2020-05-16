function [ErrorFeatures_curID] = GetErrorsFeature(errors_curID, datesFrame, windowSize, normalizeCountByWindowSize, sample_first,sample_rate)
    
    errors_types = {'error1','error2','error3','error4','error5'};
%%
    curID = errors_curID.machineID(1);
    firstDate = datesFrame(1);  lastDate = datesFrame(2);
    datetime = (firstDate:hours(1):lastDate)';
    Z = zeros(length(datetime),1);
    tmpTT = timetable(datetime,Z,'VariableNames',{'tmpVar'});
    errors_expanded = synchronize(tmpTT,errors_curID);
    errors_expanded.tmpVar = [];
    errors_expanded.machineID = []; %ones(length(datesVec),1) * cur_id;
    errsInColumns = [];
    
%%
    for i=1:length(errors_types)
        indexesLogical = strcmp(errors_expanded.errorID , errors_types(i));
        X = Z; X(indexesLogical) = 1;
        tmp = timetable(datetime,X);
        tmp.Properties.VariableNames = errors_types(i);
        errsInColumns = [errsInColumns tmp];
    end
    tmp = errors_expanded; tmp.errorID = [];
    errors_1hourSampled = [tmp errsInColumns];
%%

    func = @(x) movsum(x,[windowSize-1 0]);
    errors_per1hour_sumOverWindow = varfun(func,errors_1hourSampled);
    errors_per1hour_sumOverWindow.Properties.VariableNames = ...
         cellfun(@(x) [x '_over_' num2str(windowSize) 'hrs'], errors_types,'uni',false);
    if normalizeCountByWindowSize == true
        errors_per1hour_sumOverWindow.Variables = errors_per1hour_sumOverWindow.Variables / windowSize;
        errors_per1hour_sumOverWindow.Properties.VariableNames = ...
         cellfun(@(x) [x '_PrcntOver_' num2str(windowSize) 'hrs'], errors_types,'uni',false);
    end
    ErrorFeatures_curID = errors_per1hour_sumOverWindow(sample_first:sample_rate:end,:);
    
    

end


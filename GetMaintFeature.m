function [MaintFeature_curID] = GetMaintFeature(maint_curID, datesFrame, sample_first,sample_rate)
    
    comps_types = {'comp1','comp2','comp3','comp4'};
%%
    curID = maint_curID.machineID(1);
    firstDate = min([datesFrame(1) , min(maint_curID.datetime)]);
    lastDate = max([datesFrame(2) , max(maint_curID.datetime)]);
    datesVec = (firstDate:hours(1):lastDate)';
    Z = zeros(length(datesVec),1);
    tmpTT = timetable(datesVec,Z,'VariableNames',{'tmpVar'});
    maints_expanded = synchronize(tmpTT,maint_curID);
    maints_expanded.tmpVar = [];
    maints_expanded.machineID = []; %ones(length(datesVec),1) * curID;
    maintsInColumns = [];
%%
    for i=1:length(comps_types)
        indexesLogical = strcmp(maints_expanded.comp , comps_types(i));
        X = Z; X(indexesLogical) = 1;
        tmp = timetable(datesVec,X);
        tmp.Properties.VariableNames = comps_types(i);
        maintsInColumns = [maintsInColumns tmp];
    end
    tmp = maints_expanded; tmp.comp = [];
    maints_1hourSampled = [tmp maintsInColumns];
    
    %%
    firstDate = datesFrame(1); lastDate = datesFrame(2);
    datetime = (firstDate:hours(1):lastDate)';
    MaintFeature_curID = timetable(datetime,zeros(length(datetime),1),'VariableNames',{'tmpVar'});
    for i=1:length(comps_types)
        curCompVec = maints_1hourSampled(:,i);
        curColumnName = {['sincelast' curCompVec.Properties.VariableNames{:}]};
        curCompVec = curCompVec.Variables;
        curSinceLastVec = GetSinceLastForCompCoulumn(curCompVec);
        tmp = timetable(datesVec,curSinceLastVec,'VariableNames',curColumnName);
        tmp = tmp(tmp.datesVec >= firstDate & tmp.datesVec <= lastDate,:);
        MaintFeature_curID = [MaintFeature_curID tmp];
    end
    MaintFeature_curID.tmpVar = [];
    MaintFeature_curID = MaintFeature_curID(sample_first:sample_rate:end,:);
    
end

%%
function sinceLastVec = GetSinceLastForCompCoulumn(compVec)
    sinceLastVec = zeros(length(compVec),1);
    sum = 0;
    for i=1:length(sinceLastVec)
       if compVec(i) == 1, sum = 0;
       else, sum = sum + 1/24; % days passed
       end
       sinceLastVec(i) = sum;           
    end
end

function  FailuresTimeStamped = GetMachineRUL(failures_curID, datesFrame, sample_first,sample_rate)
%     compIsx = cellfun(@(x) strcmp(x,['comp' num2str(failureIDToGet)]),failures_curID.failure); 
%     failures_curID(~compIsx,:) = [];
%     if(isempty(failures_curID))
%         FailuresTimeStamped = [];
%         return;
%     end
    firstDate = datesFrame(1);  lastDate = datesFrame(2);
    datetime = (firstDate:hours(1):lastDate)';
    datetime = datetime(sample_first:sample_rate:end);
    timeSteps = (1:length(datetime))';
    scenario_num = ones(length(datetime),1);
    FailuresTimeStamped = timetable(datetime,scenario_num,timeSteps);
    for i=1:height(failures_curID)
       failure_time = failures_curID.datetime(i);
       index = find(FailuresTimeStamped.datetime < failure_time,1,'last') + 1;
       FailuresTimeStamped.timeSteps(index:end) = 1:(length(datetime)-index+1);
       FailuresTimeStamped.scenario_num(index:end) = i+1;
    end
    lastFailureTime = max(failures_curID.datetime);
    %% delete rows after last error: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !!!!!      !!!!!!!        !!!!!
    FailuresTimeStamped(FailuresTimeStamped.datetime >= lastFailureTime,:) = []; 
    
end


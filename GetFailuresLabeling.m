function [FailureLabeled] = GetFailuresLabeling(failures_curID, datesFrame,failureWindowSize, sample_first,sample_rate)

firstDate = datesFrame(1);  lastDate = datesFrame(2);
datesVector = (firstDate:hours(1):lastDate)';

tDates = timetable(datesVector);

% convert failures to double

failures_curID.failure = cellfun(@(x) str2num(x(end)),failures_curID.failure);

fullFailure = synchronize(tDates,failures_curID,'union','fillwithconstant','Constant',0);
% labeling 

func = @(x) movsum(x,[0 failureWindowSize-1]);
FailureLabeled = varfun(func,fullFailure(:,2));

FailureLabeled = FailureLabeled(sample_first:sample_rate:end , :);

%TODO: two others failures - do like errors features?
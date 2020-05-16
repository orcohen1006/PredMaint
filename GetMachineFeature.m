function [tabelMachines] = GetMachineFeature(machines_curID, datesFrame, sample_first,sample_rate)

firstDate = datesFrame(1);  lastDate = datesFrame(2);
datetime = (firstDate:hours(1):lastDate)';
datetime = datetime(sample_first:sample_rate:end);
machines_curID.model = str2num(machines_curID.model{:}(end));
% convert failures to double
machines_curID = repmat(machines_curID,size(datetime,1),1);
tabelMachines = table2timetable(machines_curID(:,2:3),'RowTimes',datetime);

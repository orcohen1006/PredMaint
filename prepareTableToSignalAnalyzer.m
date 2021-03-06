%% TODO

%% 

%load('..\data\dataTables.mat');
MACHINE_NUM = 100;
%% 
for i=1:1
    curID = 2;
   
    teles_curID = telemetry(telemetry.machineID == curID,:);
    teles_curID.machineID = [];
    failures_curID = failures(failures.machineID == curID,:);
    B = varfun(@normalize,teles_curID);
    B = varfun(@(x) smoothdata(x,'movmean',6),B);
    
    
   
%% 
end
timeHours = hours(1:height(B))';
F = timetable(B.datetime,zeros(height(B),1));
failures_curID.failure = cellfun(@(x) str2num(x(5)),failures_curID.failure);
F = synchronize(F,failures_curID,'union','fillwithconstant','Constant',0);
F.Time = timeHours;
F.Var1 = [];
F.machineID = [];
B.datetime = timeHours;

function y = normalize(x)
    y = x - mean(x);
    yAbsMax = max(abs(y));
    y = y./ yAbsMax;
end
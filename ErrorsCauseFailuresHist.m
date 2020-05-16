clear; close all;

N_hours = 48; % hours to look ahead from each error
load('..\data\dataTables.mat');
errors.errorID = categorical(errors.errorID);
failures.failure = categorical(failures.failure);
failure_types = categories(failures.failure);
errors_types = categorical(unique(errors.errorID));
num_errros_types = length(errors_types);
Hfigs = [];
%% run on all errors by types
for i=1:num_errros_types
   curError = errors(errors.errorID == errors_types(i),:);
   tmp=[];
   for j=1:height(curError)% run on all from this type
        error_date = curError.datetime(j);
        % same machine, failures that accure afetr max. N_hours
        ind = find(failures.datetime >= error_date & failures.datetime <= error_date + hours(N_hours)...
            & failures.machineID == curError.machineID(j));
        if isempty(ind)
            tmp = [tmp; categorical({'None'})];
        else
            tmp = [tmp; failures.failure(ind)];
        end
   end
   f = figure;histogram(tmp);grid on;
   title(['error type: ' + string(errors_types(i)) newline ...
            'failure types in future ' num2str(N_hours) ' hours window']);
   
   Hfigs = [Hfigs f];
end

% GET_EVENTS - Collection of events occurring within a recording time period
%
% Inputs: 
% patient   = patient directory
% record    = 'pre' or 'post' condition, based on when the recording took place 
% times     = datetime vector
%
% Outputs:
% events    = mx1 matrix of events occurring during recording. The value of 
%             m is based on the input datetime vector
% ann_times = mx2 matrix of annotated times, where the first column is the 
%             starting time of the recording and the second column is the
%             finishing time. The value of m depends on the number of "txt" 
%             files for each patient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [events, ann_times] = get_events(patient, record, times)

events = NaN(length(times),1);

files = dir(strcat(patient.folder,'\',patient.name,'\',record,'\txt'));
ann_times = NaT(length(files)-2,2);
ann_times.Format = 'HH:mm:ss';

am = 0; % Record whether midnight was passed
for i = 3:length(files)
    lines = readlines(strcat(files(i).folder,'\',files(i).name));
    lines = lines(18:end-1);

    % Start and stop times of annotation file
    start = strsplit(char(lines(1)));
    ann_times(i-2,1) = datetime(strcat("2022-9-21 ", start{2})) + am*days(1);
    stop = strsplit(char(lines(end)));
    ann_times(i-2,2) = datetime(strcat("2022-9-21 ", stop{2})) + am*days(1);

    if ann_times(i-2,2) <= ann_times(i-2,1) % Midnight passed
        am = 1;
        ann_times(i-2,2) = ann_times(i-2,2) + days(1);
    end
    
    % Replacement of the NaN values in "events" with the corresponding coded value
    for k = 1:length(times)
        line = lines(contains(lines, string(times(k))));
        if line ~= ""
            chars = char(line);
            events(k) = let_to_num(chars(1:2));
        end
    end
end
end
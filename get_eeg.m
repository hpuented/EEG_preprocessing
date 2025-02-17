% GET_EEG - Collection of 3 hours of EEG data from edf file and alignment with
%           annotation data
%
% Inputs: 
% patient   = patient directory
% record    = 'pre' or 'post' condition, based on when the recording took place 
% times     = datetime vector
% events    = events occurred during recording
% ann_times = recording start and end time
%
% Outputs:
% data    = structure array with the EEG features (label, trial, time, 
%           fsample and cfg)
% daytime = date and time array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data, daytime] = get_eeg(patient, record, times, events, ann_times, duration)

files = dir(strcat(patient.folder,'\',patient.name,'\',record,'\edf'));
datas = cell(length(files)-2,1);
channels = {'all','-ECGL','-ECGR','-EKG1','-EKG2','-A1','-A2',...
        '-ECG EKG-REF','-Event EVENT-REF','-EEG EOG_li-REF',...
        '-EEG A1-REF','-EEG A2-REF','-ECG+-Gnd','-EEG A1-Ref',...
        '-EEG A2-Ref', '-EDF Annotations', '-Ref'};

% STEP 1. Concatenate separate edf files
for i = 3:length(files)
    disp(files(i).name)

    % CAUTION: Add 'EDF+C_Online' in line 70 in signal.internal.edf.validateEDF
    eeg_info = edfinfo(strcat(files(i).folder,'\',files(i).name));
    eeg_start = str2double(strsplit(eeg_info.StartTime, '.')) * [3600; 60; 1]; % Starting information in seconds

    % Raw EDF data 
    cfg            = [];
    cfg.dataset    = strcat(files(i).folder,'\',files(i).name);
    cfg.continuous = 'yes';
    cfg.channel    = channels;
    datas{i-2} = ft_preprocessing(cfg); % Preprocessing of continuous data

    % Alignment of annotation and EEG data
    td = seconds(timeofday(ann_times(i-2,1))) - eeg_start; % Time difference between annotation and edf recording
    dur = seconds(ann_times(i-2,2) - ann_times(i-2,1)) + 30; % +30 s because of the duration of the last time listed
    cfg = [];
    cfg.begsample = 1 + datas{i-2}.fsample * td; % Beginning sample
    cfg.endsample = cfg.begsample + dur * datas{i-2}.fsample - 1; % Ending sample
    datas{i-2} = ft_redefinetrial(cfg, datas{i-2}); % Re-define beginning and ending in the data

    % Epoch data (division in 30 seconds-length windows)
    cfg = [];
    cfg.length = 30;
    cfg.overlap = 0;
    datas{i-2} = ft_redefinetrial(cfg, datas{i-2});
end

cfg = [];
cfg.keepsampleinfo = 'no';
cfg.appenddim = 'rpt';
data = ft_appenddata(cfg, datas{:});
clear datas

% STEP 2. Get daytime vector corresponding to time of day of each trial (30 seconds window length)
daytime = NaT(1,length(data.time));
ind = 1;
for i = 1:size(ann_times,1)
    temp = (ann_times(i,1):seconds(30):ann_times(i,2));
    daytime(ind:ind+length(temp)-1) = temp;
    ind = ind + length(temp);
end

% STEP 3. Obtain 3 hrs of awake data
cfg = [];

% First is the index of the trial closest to 15:00 (time defined in setup)
[~, first] = min(abs(daytime - times(1)));

% Offset is the amount of trials between recording start and 15:00 (time defined in setup)
[~, offset] = min(abs(daytime - times(1)));
offset = offset - 1;

% Select all awake from first long awake accumulating to 3 hrs
aw = find(rmmissing(events) == 1) + offset;
aw = aw(aw >= first);
cfg.trials = aw(1:min(duration,length(aw)));

daytime = daytime(cfg.trials);
data = ft_redefinetrial(cfg, data);
end
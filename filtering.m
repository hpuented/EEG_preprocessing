addpath C:\Users\helen\Documentos\UT\2A\2.Project\3.Code\FieldTrip
ft_defaults

files = dir('C:\Users\helen\Documentos\UT\2A\2.Project\3.Code\Scripts\data\pre-processing\raw');
files = files(3:end);

saving_folder = 'C:\Users\helen\Documentos\UT\2A\2.Project\3.Code\Scripts\data\pre-processing\filtered\';

notch_freqs = {[9.5,13.5,19,27,27.25,38,47.375,48.75,50,54.25,58.25,67.75], [50], [9.5,13.5,19,27,27.25,47.375,48.75,50,54.25,58.25,67.75], [30,50,56,60], [50,60,67.75], [30,50,60], [50,55.125,69.633], [50], [9.5,13.5,19,27,27.25,29.75,38,47.375,48.75,50,54.25,58.25,67.75], [50],...
    [50], [16.625,33.375,40.375,50,59.625,66.625], [50,67.75], [50], [50,66], [50], [9.5,13.5,19,27,27.25,28.5,29.75,38,39.25,47.375,48.75,50,54.25,56.88,58.25,67.75], [], [9.5,13.5,19,27,27.25,30,38,47.375,48.75,50,54.25,58.25,60,67.75], [30,50,60]};

bandwidths = {[0.25,0.125,0.25,0.125,0.125,0.125,0.125,0.125,0.25,0.125,0.125,2], [0.25], [0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.5,0.125,0.125,1], [0.25,0.25,0.375,0.25], [0.375,0.125,1], [0.25,0.25,0.25], [0.5,0.5,0.125], [1], [0.125,0.125,0.25,0.125,0.125,0.125,0.125,0.125,0.125,1.25,0.125,0.125,1], [0.25],...
    [0.35], [0.125,0.375,0.25,0.375,0.5,0.25], [0.625,0.25], [0.125], [0.125,0.25], [0.125], [0.25,0.125,0.25,0.125,0.125,0.125,0.25,0.125,0.125,0.125,0.125,1,0.125,0.125,0.125,1], [], [0.125,0.125,0.25,0.125,0.125,0.125,0.125,0.125,0.125,0.25,0.125,0.25,0.125,2], [0.125,0.125,0.125]};

%% Filtering
for i = 1:length(files)
    fprintf('Filtering EEG data from: %s.\n', files(i).name)

    filename = strcat(files(i).folder,'\',files(i).name);
    varname = who('-file', filename); 
    varname = varname{1};
    eeg_patient = load(filename).(varname);

    % Filtering: Bandpass (0.25 to 70 Hz), Notch (50 Hz), Notch (harmonics, patient dependent) & CAR
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [0.25 70];
    %cfg.bpfiltord = 4; % Butterworth type and order 4 are default

    cfg.reref= 'yes';
    cfg.refmethod = 'avg';
    cfg.refchannel = 'all';

    if ~isempty(notch_freqs{i})
        cfg.dftfilter = 'yes';
        cfg.dftreplace = 'neighbour';
        cfg.dftfreq = notch_freqs{i};
        cfg.dftbandwidth = bandwidths{i}/2;
        cfg.dftneighbourwidth = ones(1, length(cfg.dftfreq));
    end

    eeg_patient.eeg_data = ft_preprocessing(cfg, eeg_patient.eeg_data);
    eeg_patient.eeg_data = rmfield(eeg_patient.eeg_data, 'sampleinfo'); % Remove, otherwise problems in next steps

    if contains(varname,'pre')
        eeg_patient_pre_filt = eeg_patient;
        save(strcat(saving_folder, eeg_patient_pre_filt.name,'_pre_filtered.mat'), 'eeg_patient_pre_filt', '-v7.3');
    else
        eeg_patient_post_filt = eeg_patient;
        save(strcat(saving_folder, eeg_patient_post_filt.name,'_post_filtered.mat'), 'eeg_patient_post_filt', '-v7.3');
    end
end
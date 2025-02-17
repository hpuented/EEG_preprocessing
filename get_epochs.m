addpath C:\Users\helen\Documentos\UT\2A\2.Project\3.Code\FieldTrip
ft_defaults

files = dir('C:\Users\helen\Documentos\UT\2A\2.Project\3.Code\Scripts\data\pre-processing\filtered');
files = files(3:end);

saving_folder = 'C:\Users\helen\Documentos\UT\2A\2.Project\3.Code\Scripts\data\pre-processing\epoch_selection\';



% GET_EPOCHS - Collection of good epochs using spectogram
%
% Inputs: 
% files          = filtered eeg directory
%
% Outputs:
% eeg_patient    = reconstructed 1-hour eeg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eeg_patient = get_epochs(files)
files = files(3:end);

for i = 1:length(files)
    fprintf('Selecting good epochs from: %s.\n', files(i).name)

    filename = strcat(files(i).folder,'\',files(i).name);
    varname = who('-file', filename); 
    varname = varname{1};
    eeg_patient = load(filename).(varname);

    for z = 1:4
        if z == 1
            freq_percent = 80;
        elseif z == 2
            freq_percent = 60;
        elseif z == 3
            freq_percent = 40;
        else
            freq_percent  = 30; % 20 is the best but not enough data for all patients (> 24-hours needed)
        end

        % Step 5. Epochsxchannel percentage matrix 
        percentage_matrix_spec = NaN(length(eeg_patient.eeg_data.trial), length(eeg_patient.eeg_data.label));
    
        for j = 1:length(eeg_patient.eeg_data.label)
    
            % Step 1. Spectogram computation
            cfg = [];
            cfg.channel = eeg_patient.eeg_data.label{j,1};
            cfg.method = 'mtmfft';
            cfg.taper = 'dpss';
            cfg.tapsmofrq  = 0.2;
            cfg.pad = 'nextpow2';
            cfg.foi = 0:1:70;
            cfg.keeptrials = 'yes';
            TFmult_j = ft_freqanalysis(cfg, eeg_patient.eeg_data);
            Sxx_j = squeeze(TFmult_j.powspctrm).';
    
            % Step 2. Mean and standard deviation for each frequency
            for k = 1:size(Sxx_j, 1)
                means(k,1) = mean(Sxx_j(k,:));
                stds(k,1) = std(Sxx_j(k,:));
            end
    
            % Step 3. Potential artifacts detection
            detection_matrix_j = NaN(size(Sxx_j));
            for m = 1:size(Sxx_j, 1) % Rows
                for n = 1:size(Sxx_j, 2) % Columns
                    if ((Sxx_j(m,n) <= (means(m)-stds(m))) || (Sxx_j(m,n) >= means(m)+stds(m)))
                        detection_matrix_j(m,n) = 0; % Bad epoch
                    else 
                        detection_matrix_j(m,n) = 1; % Good epoch
                    end
                end
            end
    
            % Step 4. Percentage of frequencies that marked an epoch as bad (with a 0)
            for k = 1:size(detection_matrix_j, 2)
                percentage_matrix_spec(k,j) = (sum(detection_matrix_j(:,k) == 0)/size(detection_matrix_j,1))*100;
            end
        end

        epoch_detection_sm = NaN(size(percentage_matrix_spec,1), 1); % Change 360 ---> size(percentage_matrix_spec,1)
        for p = 1:size(percentage_matrix_spec,1)
            channel_percentage_i = (sum(percentage_matrix_spec(p,:) >= freq_percent)/size(percentage_matrix_spec, 2))*100;
            if channel_percentage_i >= 10
                epoch_detection_sm(p) = 0; % Bad epoch
            else
                epoch_detection_sm(p) = 1; % Good epoch
            end
        end

        good_epochs = find(epoch_detection_sm == 1);

        eeg_patient.eeg_data.trial = eeg_patient.eeg_data.trial(good_epochs);
        eeg_patient.eeg_data.time = eeg_patient.eeg_data.time(good_epochs);
        eeg_patient.daytime = eeg_patient.daytime(good_epochs);
    end
end

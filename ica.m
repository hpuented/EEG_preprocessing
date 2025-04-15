%% Step 1. ICA components
for i = 1:length(files)
    fprintf('ICA decomposition: %s.\n', files(i).name)

    filename = strcat(files(i).folder,'\',files(i).name);
    varname = who('-file', filename); 
    varname = varname{1};
    eeg_patient = load(filename).(varname);

    % Remove NaN channels
%     if anynan(eeg_patient.eeg_data.trial{1})
%         index = find(isnan(eeg_patient.eeg_data.trial{1}(:,1)));
%         eeg_patient.eeg_data.label(index) = [];
% 
%         trials = cell(1, length(eeg_patient.eeg_data.trial));
%         for j = 1:length(eeg_patient.eeg_data.trial)
%             trials{j} = rmmissing(eeg_patient.eeg_data.trial{j});
%         end
%         eeg_patient.eeg_data.trial = trials;
%     else
%     end
    if anynan(eeg_patient.eeg_data.trial{1})
        index = find(isnan(eeg_patient.eeg_data.trial{1}(:,1)));
        channels = eeg_patient.eeg_data.label;
        channels(index) = [];
    
        cfg = [];
        cfg.channel = channels;
        eeg_patient.eeg_data = ft_selectdata(cfg, eeg_patient.eeg_data);
    end

    % Selection of 1-hour of data
    eeg_patient.daytime = eeg_patient.daytime(1:120);
    eeg_patient.eeg_data.trial = eeg_patient.eeg_data.trial(1:120);
    eeg_patient.eeg_data.time = eeg_patient.eeg_data.time(1:120);

    % ICA 
    nChannel = length(eeg_patient.eeg_data.label);

    cfg = [];
    cfg.method = 'runica'; 
    cfg.numcomponent = nChannel;
    components = ft_componentanalysis(cfg, eeg_patient.eeg_data);

    if contains(varname,'pre')
        save(strcat(saving_folder, eeg_patient.name,'_pre_ICA_comp.mat'), 'components', '-v7.3');
    
    else
        save(strcat(saving_folder, eeg_patient.name,'_post_ICA_comp.mat'), 'components', '-v7.3');
    end
end

%% Step 2. Identifying and removing the artifacts (patient by patient)
%% Plots
% Time course of the components
cfg = [];
cfg.layout = layout;
cfg.viewmode = 'component';
ft_databrowser(cfg, components)

% Topoplot
figure
cfg = [];
cfg.component = 1:length(components.label);
cfg.layout    = layout;
cfg.comment   = 'no';
ft_topoplotIC(cfg, components)

%% Remove the artifacts
comp_files = dir('...\ica\components');
comp_files = comp_files(3:end);

data_files = data_files(3:end);

artifacts = {[2 4 10]; [1 2]; [2 4]; [1 3]; [1 2]; [1 3 13]; [1 2 19]; [4]; [3 5 6]; [1 2 8];
    [1 2 3 10 11]; [1 2 9]; [1 2]; [2 3]; [2 3 14]; [2 3 7]; [2 3 5 7]; [1 2 7]; [2 5 13]; [1 2 3 9]};

for i = 1:length(data_files)
    fprintf('Artifact removal from: %s.\n', data_files(i).name)

    % ICA components
    load([comp_files(i).folder,'\', comp_files(i).name]);

    % EEG data
    filename = strcat(data_files(i).folder,'\',data_files(i).name);
    varname = who('-file', filename); 
    varname = varname{1};
    eeg_patient = load(filename).(varname);

    % Remove NaN channels
    if anynan(eeg_patient.eeg_data.trial{1})
        index = find(isnan(eeg_patient.eeg_data.trial{1}(:,1)));
        channels = eeg_patient.eeg_data.label;
        channels_new = eeg_patient.eeg_data.label; channels_new(index) = [];
    
        cfg = [];
        cfg.channel = channels_new;
        eeg_patient.eeg_data = ft_selectdata(cfg, eeg_patient.eeg_data);
    end

    % Selection of 1-hour of data
    eeg_patient.daytime = eeg_patient.daytime(1:120);
    eeg_patient.eeg_data.trial = eeg_patient.eeg_data.trial(1:120);
    eeg_patient.eeg_data.time = eeg_patient.eeg_data.time(1:120);

    % Artifact rejection
    cfg = [];
    cfg.component = artifacts{i};
    eeg_artremoval = ft_rejectcomponent(cfg, components, eeg_patient.eeg_data);
    eeg_patient.eeg_data = eeg_artremoval;

    % Adjust labels and NaN values
    if exist('index', 'var')
        for j = 1:length(index)
            index_j = index(j);
            new_trials = cell(1,length(eeg_patient.eeg_data.trial));
            for k = 1:length(eeg_patient.eeg_data.trial)
                trial_i = eeg_patient.eeg_data.trial{k};
                new_trials{k} = [trial_i(1:index_j-1,:); NaN(1, length(trial_i)); trial_i(index_j:end,:)];
            end
            eeg_patient.eeg_data.trial = new_trials;
            eeg_patient.eeg_data.label = channels;
        end
    end
    clear index

    if contains(varname,'pre')
        eeg_patient_pre_final = eeg_patient;
        save(strcat(saving_folder, eeg_patient_pre_final.name,'_pre_final.mat'), 'eeg_patient_pre_final', '-v7.3');
    else
        eeg_patient_post_final = eeg_patient;
        save(strcat(saving_folder, eeg_patient_post_final.name,'_post_final.mat'), 'eeg_patient_post_final', '-v7.3');
    end
end


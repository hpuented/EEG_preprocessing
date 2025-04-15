function [entropy] = get_SampEn(StimEEG_condition)

entropy = cell(length(StimEEG_condition), 1);

for sub_i = 1:length(StimEEG_condition)
    eeg_data = StimEEG_condition{sub_i}.eeg_data;
    entropyxsub = zeros(length(eeg_data.label), length(eeg_data.trial));
    fprintf('Obtaining SampEn from: %s.\n', StimEEG_condition{sub_i}.name)

    for trial_j = 1:length(eeg_data.trial)
        for chan_k = 1:length(eeg_data.label)
            signalxchan = eeg_data.trial{1,trial_j}(chan_k,:);

            if ~(isnan(signalxchan))
                entropyxsub(chan_k, trial_j) = sampen(signalxchan, 2, 0.2, 'chebychev');
            end

        end
    end

    entropy{sub_i} = entropyxsub;
end
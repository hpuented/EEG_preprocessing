function FFT_field = get_FFT(EEG_field)
    
FFT_field = cell(length(EEG_field), 1);

cfg = [];
cfg.output = 'pow';
cfg.method = 'mtmfft';
cfg.foi = 0:0.125:30;
cfg.tapsmofrq = 0.5;
cfg.pad ='nextpow2';
cfg.keeptrials = 'yes';
cfg.channel = 'all';
cfg.taper = 'hanning';

for i = 1:length(FFT_field)
    disp(EEG_field{i}.name)
    FFT_field{i} = EEG_field{i};
    if ~isempty(EEG_field{i})
        FFT_field{i}.eeg_data = ft_freqanalysis(cfg, EEG_field{i}.eeg_data);
    end
end
end
function [ConnectivityPre,ConnectivityPost,ConnectivityPre_Areas,ConnectivityPost_Areas,GlobalChConnPre,GlobalChConnPost] = get_dwPLI(EEG_PreStim,EEG_PostStim,channelsEEG)

Areas = {'Central Left','Central Right','Frontal Left','Frontal Right','Temporal Left','Temporal Right','Parietal Left','Parietal Right','Occipital'};
AllAreas = cat(2, Areas', Areas');
ChannelsxAreas = {{'C3'},{'C4'},{'Fp1','F3'},{'Fp2','F4'},{'T1','T3','T5','F7',},{'T2','T4','T6','F8'},{'P3'},{'P4'},{'O1','O2'}};

nsub = length(EEG_PreStim);

%%
ConnectivityPre = cell(nsub,1);
ConnectivityPost = cell(nsub,1);

whatMeas = 'wpli_debiased';
nameFieldConnectivity = strcat(whatMeas,'spctrm');

for is = 1:nsub
    disp(EEG_PreStim{is}.name)

    currentPre = EEG_PreStim{is}.eeg_data;
    currentPost = EEG_PostStim{is}.eeg_data;
    ConnectivityPre{is} = {};
    ConnectivityPost{is} = {};

    if ~isempty(currentPre)

        cfgF = [];
        cfgF.output = 'fourier';
        cfgF.method = 'mtmfft';
        cfgF.pad = 'nextpow2';
        cfgF.tapsmofrq  = 1;
        cfgF.foi = 1:0.25:30;
        cfgF.keeptrials = 'yes';
        cfgF.channel    = 'all';

        freqfourierPre = ft_freqanalysis(cfgF, currentPre);
        freqfourierPost = ft_freqanalysis(cfgF, currentPost);

        cfgC            = [];
        cfgC.method     = 'wpli_debiased';

        fdfourierPre = ft_connectivityanalysis(cfgC, freqfourierPre);
        fdfourierPost = ft_connectivityanalysis(cfgC, freqfourierPost);
        
       %Connectivity.(WhatSubject).(WhatSide).labelcmb = fdfourierPost.labelcmb;
        ConnectivityPost{is}.dimord = fdfourierPost.dimord;
        ConnectivityPost{is}.freq = fdfourierPost.freq;

        if sum(strcmp('dof',fieldnames(fdfourierPost))) > 0
            ConnectivityPost{is}.dof = fdfourierPost.dof;
        end

        ConnectivityPost{is}.cfg = fdfourierPost.cfg;
        ConnectivityPost{is}.(nameFieldConnectivity)= fdfourierPost.(nameFieldConnectivity);
        
        ConnectivityPre{is}.dimord = fdfourierPre.dimord;
        ConnectivityPre{is}.freq = fdfourierPre.freq;

        if sum(strcmp('dof',fieldnames(fdfourierPre))) > 0
            ConnectivityPre{is}.dof = fdfourierPre.dof;
        end

        ConnectivityPre{is}.cfg = fdfourierPre.cfg;
        ConnectivityPre{is}.(nameFieldConnectivity)= fdfourierPre.(nameFieldConnectivity);
    end
end

% Area by area connectivity
[ConnectivityPre_Areas, GlobalChConnPre] = get_area_conn(nsub, channelsEEG, length(fdfourierPre.freq), ConnectivityPre, Areas, ChannelsxAreas, AllAreas);
[ConnectivityPost_Areas, GlobalChConnPost] = get_area_conn(nsub, channelsEEG, length(fdfourierPost.freq), ConnectivityPost, Areas, ChannelsxAreas, AllAreas);

end

%% get_area_conn function
function [Connectivity_Areas, GlobalChConn] = get_area_conn(nsub, channelsEEG, nfreqs, Connectivity, Areas, ChannelsAreas, AllAreas)

Connectivity_Areas = cell(nsub, 1);
currentChannels = channelsEEG;

%GlobalPostConnectivityForEachChannel=zeros(14,1);
GlobalChConn = zeros(length(currentChannels), nfreqs, nsub);

%OnlyChannels=[1,2,3,4,6,7,8,9,10,11,12,14,15,16];
k = 1;
for is = 1:nsub
    currentConn = Connectivity{is};
    
    if ~isempty(currentConn)
        Connectivity_Areas{is} = {};
        
        connSpectrum = currentConn.wpli_debiasedspctrm; % 3D matrix: Chan x Chan x Freq;
        finalAreasConnMatrix = zeros(length(Areas), length(Areas), size(connSpectrum,3)); % 3D: region x region x freq
        
        % for each channel, computing glob conn
        % edit nikola: this is simply the mean of the connectivity of each
        % channel to each other channel:
        % squeeze(mean(ConnectivityPost{1}.wpli_debiasedspctrm,2,'omitnan'))
        % -> ie. from (chan x chan x freq) to (chan x freq)
        % for each subject in 3rd dimension
        
        GlobalChConn(:,:,is) = squeeze(mean(connSpectrum,2,"omitnan"));
        
        for i_a1 = 1:length(Areas)
            for i_a2 = 1:length(Areas)
                thisA1A2 = [];
                whichChannelsA1 = ChannelsAreas{i_a1};
                for wca1_index = 1:length(whichChannelsA1)
                    whichCh = strcmp(currentConn.cfg.channel,whichChannelsA1{wca1_index});
                    
                    for wca2_index = 1:size(connSpectrum,2) % for all the other channels
                        secondCh = currentConn.cfg.channel{wca2_index};
                        
                        if ismember(secondCh, ChannelsAreas{i_a2})
                            thisA1A2 = [thisA1A2; connSpectrum(whichCh,wca2_index,:)];
                        end
                    end
                end
                
                if i_a1 ~= i_a2
                    finalAreasConnMatrix(i_a1,i_a2,:) = mean(thisA1A2,1);
                else
                    finalAreasConnMatrix(i_a1,i_a2,:) = repelem(1,nfreqs);
                end
            end
        end
        
        Connectivity_Areas{is}.wpli_debiasedspctrm = finalAreasConnMatrix;
        Connectivity_Areas{is}.labelcmb = AllAreas;
        Connectivity_Areas{is}.dimord = 'chan_chan_freq';
        Connectivity_Areas{is}.freq = currentConn.freq;
        Connectivity_Areas{is}.cfg = currentConn.cfg;
        k = k+1;
    end
end
end
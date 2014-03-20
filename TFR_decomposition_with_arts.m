%% Clean script do everything

addpath /usr/local/MATLAB/R2011a/toolbox/fieldtrip-20130311/

ft_defaults();

% Choose: load cleaned or full data
% load data_rearranged.mat % Complete dataset with artifacts and everything

load data_cl_20130424.mat
data_CTR=data_CTR_cl;
data_MWU=data_MWU_cl;
data_SEM=data_SEM_cl;
clear *_cl;


nSubj=length(data_MWU);

%% Preprocessing
% Demean

cfg=[];
cfg.demean = 'yes';

for i=1:nSubj
    data_MWU_dm(i) = ft_preprocessing(cfg, data_MWU(i));
    data_SEM_dm(i) = ft_preprocessing(cfg, data_SEM(i));
    data_CTR_dm(i) = ft_preprocessing(cfg, data_CTR(i));
end
clear i data_MWU data_SEM data_CTR

%% TF-analysis
% 
%  cfg = [];
%     cfg.method     = 'wavelet';                
%     cfg.width      = 7;         % If my lowest freq of interest is 4Hz, and my last possible
%                                 % time-window is 600ms in lenght
%                                 % duration=width/F/pi
%                                 % BUT: Diego recommends 5...
%     cfg.output     = 'pow';     % return the power-spectra. 
%     cfg.foi        = 1:1:50;	% Frequency of interest: From 1 to 50 Hz in 
%                                 % steps of 1Hz             
%                                 
%     cfg.toi        = -1.8:0.064:1; % time window "slides" from -1.8 to 1s 
%                                    % (our own epoch). Could use steps of 
%                                    % 0.004s (250Hz-- sampling rate) but 
%                                    % this generates HUGE dataset. Use
%                                    % multiple of 0.004?
%                                    
%     cfg.keeptrials = 'yes';        %'yes' or 'no', return individual trials
%                                    % or average (default = 'no')            
% 
%     for i=1:nSubj
%         TFRwave_MWU(i) = ft_freqanalysis(cfg, data_MWU_dm(i));
%         TFRwave_SEM(i) = ft_freqanalysis(cfg, data_SEM_dm(i));
%         TFRwave_CTR(i) = ft_freqanalysis(cfg, data_CTR_dm(i));
% end
% clear i                               
% 
cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:2:30;                         % analysis 2 to 30 Hz in steps of 2 Hz 
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -1.8:0.04:1;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.keeptrials = 'yes';        %'yes' or 'no', return individual trials

for i=1:nSubj
    TFRwave_MWU_hann{i} = ft_freqanalysis(cfg, data_MWU_dm(i));
    TFRwave_SEM_hann{i} = ft_freqanalysis(cfg, data_SEM_dm(i));
    TFRwave_CTR_hann{i} = ft_freqanalysis(cfg, data_CTR_dm(i));

end
%% Baseline

cfg=[];
cfg.parameter = 'powspctrm';
cfg.baseline=[-0.95 -0.65];
cfg.baselinetype='relative';


for i=1:nSubj
   
        TFRwave_MWU_bc{i} = ft_freqbaseline(cfg, TFRwave_MWU_hann{i});
        TFRwave_SEM_bc{i} = ft_freqbaseline(cfg, TFRwave_SEM_hann{i});
        TFRwave_CTR_bc{i} = ft_freqbaseline(cfg, TFRwave_CTR_hann{i});
end
clear i

%save TFRwave_bc.mat *_bc
save TFRwave_bc_st_cl.mat *_bc
%%


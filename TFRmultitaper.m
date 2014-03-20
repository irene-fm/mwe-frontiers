
%%
addpath /usr/local/MATLAB/R2011a/toolbox/fieldtrip-20130311/

ft_defaults();

%% Load data without artifacts

load data_cl_20130424
nSubj=length(data_MWU_cl);

%% Preprocessing
% Demean

cfg=[];
cfg.demean = 'yes';

for i=1:nSubj
    data_MWU_dm(i) = ft_preprocessing(cfg, data_MWU_cl(i));
    data_SEM_dm(i) = ft_preprocessing(cfg, data_SEM_cl(i));
    data_CTR_dm(i) = ft_preprocessing(cfg, data_CTR_cl(i));
end
clear i data_MWU_cl data_SEM_cl data_CTR_cl
%% TF with multitapers for high frequencies, keep trials


cfg = [];
cfg.output     = 'pow';
%cfg.channel    = 'MEG';
cfg.keeptrials = 'yes'; 
cfg.method     = 'mtmconvol';
cfg.foi        = 25:2:80; % Gamma analysis
%cfg.t_ftimwin  = ones(length(cfg.foi),1).*0.5;
cfg.t_ftimwin = 5./cfg.foi; % vector 1 x numfoi, length of time window (in seconds)
                             % usual to chose a small multiple of the
                             % Raighley frequency 1/N=F; N=1/F.
cfg.tapsmofrq  =cfg.foi*0.4 ; % vector 1 x numfoi, the amount of spectral smoothing through
                               % multi-tapering. Note that 4 Hz smoothing means
                               % plus-minus 4 Hz, i.e. a 8 Hz smoothing
                               % box. Wang et al: 5Hz smoothing

% Number of tapers applied: 2*fw*tw-1=2*5*0.4=3.                               
                               
cfg.toi        = -1.8:0.04:1.0; % vector 1 x numtoi, the times on which the analysis windows
                                % should be centered (in seconds)
cfg.pad        = 'maxperlen';  

    
nSubj=34
for i=1:nSubj
        TFRmult_MWU_2(i) = ft_freqanalysis(cfg, data_MWU_dm(i));
        TFRmult_SEM_2(i) = ft_freqanalysis(cfg, data_SEM_dm(i));
        TFRmult_CTR_2(i) = ft_freqanalysis(cfg, data_CTR_dm(i));
end
%TFRmult = ft_freqanalysis(cfg, dataFIC);

%% Baseline correct, calculate averages

cfg=[];
cfg.parameter = 'powspctrm';
cfg.baseline=[-0.95 -0.65];
cfg.baselinetype='relative';

for i=1:nSubj
        TFRwave_MWU_bc{i} = ft_freqbaseline(cfg, TFRmult_MWU_2(i));
        TFRwave_SEM_bc{i} = ft_freqbaseline(cfg, TFRmult_SEM_2(i));
        TFRwave_CTR_bc{i} = ft_freqbaseline(cfg, TFRmult_CTR_2(i));
end

save TFRmult_bc_st_cl TFRwave*


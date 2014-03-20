%%
addpath ./eeglabfuncs/

% Load wavelet or hanning TFR:
%load ../new/TFRhann_avg_bc2.mat
%load  ../TFRs/TFRhann_avg_bc3.mat
%load ../TFRs/TFRmult1_avg_bc2.mat
load TFRwave_bc_st_cl.mat
%load TFRmult_bc_st_cl.mat
%% Prepare data structure for statcond

nSubj=size(TFRwave_CTR_bc, 2);

% Data structure: (1,2) cell array with (channel_freq_time_subject).
data=NaN+zeros(size(TFRwave_CTR_bc{1}.label, 1),size(TFRwave_CTR_bc{1}.freq, 2), size(TFRwave_CTR_bc{1}.time, 2), nSubj);


% chan_freq_time
for i=1:nSubj
    data_MWU(:,:,:,i)=squeeze(nanmean(TFRwave_MWU_bc{i}.powspctrm,1)); % data_MWU=chan_freq_time_subj
    data_SEM(:,:,:,i)=squeeze(nanmean(TFRwave_SEM_bc{i}.powspctrm,1));
    data_CTR(:,:,:,i)=squeeze(nanmean(TFRwave_CTR_bc{i}.powspctrm,1));
end

for i=1:27
    data_MWU(i)=squeeze(data_MWU(i));
    data_SEM(i)=squeeze(data_SEM(i));
    data_CTR(i)=squeeze(data_CTR(i));
end

    data_SEMvsCTR={data_SEM data_CTR}; % data_SEMvsCTR{cond}(chan_freq_time_subj)
    data_MWUvsCTR={data_MWU data_CTR}; 
    data_MWUvsSEM={data_MWU data_SEM}; 
    
   
    time=TFRwave_CTR_bc{1}.time;
    % Select times  0 to 0.72
    time=time(46:64); 
    
    freq=TFRwave_CTR_bc{1}.freq;
    chann=TFRwave_CTR_bc{1}.label;
    clear TFR* data data_CTR data_MWU data_SEM i nSubj
    save data_contrasts_hann_bc2.mat data_* time freq chann
    %save data_contrasts_morlet_bc3.mat data_* time freq chann
    %save data_contrasts_mult1_bc2.mat data_* time freq chann

    %% Run statcond
    
    
   %data_SEMvsCTR={data_SEMvsCTR{1}(:,:,46:64,:) data_SEMvsCTR{2}(:,:,46:64,:)};
   %data_allconds={data_MWUvsSEM{1}(:,:,46:64,:) data_MWUvsSEM{2}(:,:,46:64,:) data_MWUvsCTR{2}(:,:,43:64,: )};
   data_MWUvsSEM={data_MWUvsSEM{1}(:,:,51:58,:) data_MWUvsSEM{2}(:,:,51:58,:)};
   %data_MWUvsCTR={data_MWUvsCTR{1}(:,:,46:64,:) data_MWUvsCTR{2}(:,:,46:64,:)};

   [t df pvals]=statcond(data_MWUvsSEM, 'mode','perm','naccu',1000);
   
   %save MWUvsSEMvsCTRmult_bc2.mat t df pvals
   %save MWUvsSEMmorlet_bc3.mat t df pvals
   save MWUvsSEMhann_bc2_v3.mat t df pvals time chann freq
   %save SEMvsCTRhann_bc2.mat t df pvals

   clear t df pvals
   
   %% Explore morlet data
   
   load data_contrasts_morlet
   load MWUvsSEMmorlet
   
   %% Explore hann data
   
   load data_contrasts_hann 
   load MWUvsSEMhann
   %load SEMvsCTRhann
   
   %% Explore multi data
   
   load data_contrasts_mult1_bc2
   load MWUvsSEMmulti1_bc2.mat
   %% Explore hann data
   
   load data_contrasts_hann_bc2
   load MWUvsSEMhann_bc2.mat
%% Plots

   % Correct for multiple comparisons
   
   %p_corrected = fdr(pvals);
   
   alpha=0.1;
   [p_fdr, p_masked] = fdr(pvals, alpha, 'nonParametric');
   
   sel_time=(1:3);
   % Duda Alejandro: no me aparecen los labels del time si especifico otro
   % intervalo que no empieze en el 1?????
   
   slice(p_corrected, [], [], sel_time);
   %shading flat
   set(gca,'YTick', 1:1:size(chann, 1))
   set(gca,'YTickLabel', chann)
   set(gca,'XTick', 1:1:size(freq, 2))
   set(gca,'XTickLabel', round(freq(1,1:1:size(freq, 2))))
   set(gca,'ZTick', 1:1:size(sel_time, 2))
   set(gca,'ZTickLabel', time(sel_time))
   set(gca,'CLim',[0 0.1])
   
   %%
   
% easycapBCBL layout
    vec_elecs = [2, 4, 7, 9, 17, 19, 27, 29, 32, 34, 6, 10, 16, 20, ...
        26, 30, 8, 18, 28, 12, 14, 22, 24, 11, 15, 21, 25, 35];
    elecs = {'Fp1','Fp2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8', 'T7','T8', ...
        'P7','P8','Fz','Cz','Pz','FC1','FC2','CP1','CP2','FC5','FC6','CP5','CP6','scale'};

% Selected gamma channels
gamma_elecs={'FC5', 'T7', 'CP5', 'FC1', 'C3', 'CP1'};
lowfreq_elecs={'CP1', 'CP2', 'P3', 'Pz', 'P4', 'F7','F3','FC5','T7','C3'};

figure;
for i=1:size(vec_elecs,2)-1
   % if(find(strcmp(elecs(i), lowfreq_elecs)))
   
    subplot(7,5,vec_elecs(i));   
    %zlim([min(fdr_pval(:)) max(fdr_pval(:))]);
    %caxis([min(fdr_pval(:)) max(fdr_pval(:))]);
   % time2=time(4:19);
    %freq2=freq(4:28);
    
    
    %cm=flipud(jet);
    %colormap(cm);
    %colorbar;
     
    imagesc(time, freq, squeeze(fdr_pval(i,:,:))); %hold on;
    set(gca,'YDir','normal');
    %set(gca, 'YTick', [30, 50, 70]);
    set(gca, 'YTick', [0, 10, 20, 30]);
    set(gca, 'XTick', [0, 0.2, 0.4, 0.6]);
    set(gca, 'YTickLabel', []);
    set(gca, 'XTickLabel', []);
    set(gca, 'Xlim', [0 0.6]);
    %set(gca,'clim',[-11 11]);
    set(gca,'clim',[-3.7 3.7]);

    title(char(elecs(i)), 'fontweight','b', 'fontsize',8, 'FontName','Arial');
    %end
end;

% Scale plot
subplot(7,5,vec_elecs(size(vec_elecs,2)));
imagesc(time, freq, zeros(size(chann,1),size(time,2))); %hold on;
    set(gca,'YDir','normal');
    %set(gca, 'XTick', [30, 50, 70]);
    set(gca, 'YTick', [0, 10, 20, 30]);
    set(gca, 'XTick', [0, 0.2, 0.4, 0.6]);
    set(gca, 'Xlim', [0 0.6]);
   % xlabel('Time (s)')
    %ylabel('Freq (Hz)')
    %set(gca,'clim',[-11 11]);
    set(gca,'clim',[-3.7 3.7]);

    title(char(elecs(size(elecs,2))), 'fontweight','b', 'fontsize',8, 'FontName','Arial');

    
    %set(gca, 'YTickLabel', []);
    %set(gca, 'XTickLabel', []);
    %set(gca, 'Xlim', [0 0.6])    
 


%%

 kk=zeros(size(chann,1),size(freq,2),size(time,2));
 %kk1=(find(p_corrected<0.05));
 kk1=(find(pvals<0.05));
 kk(kk1)=1;
 fdr_pval=kk.*t;
 
 
%%
[r c]=find(squeeze(fdr_pval(find(strncmp(chann, 'F3', 2)),:,:)))

freq(r(1,1))

[r c]=find(squeeze(fdr_pval(find(strncmp(chann, 'Pz', 2)),:,:)))


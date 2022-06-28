
% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2';
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data

% extract subject ID
subjectID = [];

% separate bipolar references (create 3 big matrices)
%for bp = 1:3
bipol_01 = []; % 8609 X 6
for i = 1:length(summaryLFP_files)
    load(summaryLFP_files{i},"m", "sl")
    bipol_01 = [bipol_01; m(:,:,1)];
    subjectID = [subjectID; repmat(i,length(m(:,:,1)),1)]
end

bipol_12 = []; % 8609 X 6
for i = 1:length(summaryLFP_files)
    load(summaryLFP_files{i},"m")
    bipol_12 = [bipol_12; m(:,:,2)];
end

bipol_23 = []; % 8609 X 6
for i = 1:length(summaryLFP_files)
    load(summaryLFP_files{i},"m")
    bipol_23 = [bipol_23; m(:,:,3)];
end
%end

% create one matrix of all patients' mean LFP power per epoch (# rows) per band (6 col) per bipolar offset (3)
bipol_power = [bipol_01, bipol_12, bipol_23];

% rows (observations) = # patients (10) * # epochs per patient
% cols_h (features) =  # bands (6)
% cols_d (contact combinations) = bipolar offsets (3)

%% k-means clustering (2) 
 
%for bp = 1:3 
rng(1); 
[idx1,C1] = kmeans(bipol_01,2); 
[idx2,C2] = kmeans(bipol_12,2); 
[idx3,C3] = kmeans(bipol_23,2); 
%end 
 
rng(1) 
%for bp = 1:3 
figure 
subplot(1,3,1), funcPlot(bipol_01,C1,idx1) 
subplot(1,3,2), funcPlot(bipol_12,C2,idx2) 
subplot(1,3,3), funcPlot(bipol_23,C3,idx3) 
%end 
 
figure  
subplot(1,3,1) 
[silh1,h1] = silhouette(bipol_01,idx1,"sqEuclidean"); 
title('silhouette plot, bipol 01') 
subplot(1,3,2) 
[silh2,h2] = silhouette(bipol_12,idx2,"sqEuclidean"); 
title('silhouette plot, bipol 12') 
subplot(1,3,3) 
[silh3,h3] = silhouette(bipol_23,idx3,"sqEuclidean"); 
title('silhouette plot, bipol 23') 


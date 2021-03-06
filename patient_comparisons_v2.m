% Determine heterogeneity in PD patient LFP power per frequency band during sleep

% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2';
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data

% extract subject ID
subjectID = []; % 8609 x 1

% separate bipolar references (create 3 big matrices)
%for bp = 1:3
bipol_01 = []; % 8609 x 6
bipol_12 = []; % 8609 x 6
bipol_23 = []; % 8609 x 6
bipol_01_sleep_mean = []; % 10 row (pt) x 6 col (band)
bipol_12_sleep_mean = []; % 10 row (pt) x 6 col (band)
bipol_23_sleep_mean = []; % 10 row (pt) x 6 col (band)
for i = 1:length(summaryLFP_files)
    load(summaryLFP_files{i},"m", "sl"); % m = 1075 x 6 x 3; s = 1075 x 1
    bipol_01 = [bipol_01; m(:,:,1)];
    bipol_12 = [bipol_12; m(:,:,2)];
    bipol_23 = [bipol_23; m(:,:,3)];
    % need rows of sl that are only sleep states: col-vector logical of sl
    sl_logical = zeros(length(sl),1,'logical'); % 1075 x 1
    for j = 1:length(sl)
        if matches(sl{j},{'N1', 'N2', 'N3', 'R'}) % matches replaces strcmp
            sl_logical(j) = true; % sl{j} = 1; else 'W', sl{j} = 0
        end
    end
    bipol_01_sleep_temp = mean(m(sl_logical,:,1)); 
    bipol_01_sleep_mean = [bipol_01_sleep_mean; bipol_01_sleep_temp]; 
    bipol_12_sleep_temp = mean(m(sl_logical,:,2)); 
    bipol_12_sleep_mean = [bipol_12_sleep_mean; bipol_12_sleep_temp]; 
    bipol_23_sleep_temp = mean(m(sl_logical,:,3)); 
    bipol_23_sleep_mean = [bipol_23_sleep_mean; bipol_23_sleep_temp]; 
    subjectID = [subjectID; repmat(i,length(m(:,:,1)),1)];
end

% create one matrix of all patients' mean LFP power per epoch (# rows) per band (6 col) per bipolar offset (3)
bipol_power = [bipol_01, bipol_12, bipol_23];

% rows (observations) = # patients (10) * # epochs per patient; cols_h (features) =  # bands (6); cols_d (contact combinations) = bipolar offsets (3)

%% Determine cluster assignments
% UMAP (MatLab File Exchange)

addpath 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\umap'

[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_01);
[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_12);
[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_23);

% Connor Meehan, Jonathan Ebrahimian, Wayne Moore, and Stephen Meehan
% (2022). Uniform Manifold Approximation and Projection (UMAP)
% (https://www.mathworks.com/matlabcentral/fileexchange/71902), MATLAB
% Central File Exchange.

%% PCA (linear dimensionality reduction, assessment of variance)
% normalize data
% % for bp = 1:3
figure
[coeff1, score1, latent1] = pca(bipol_01);
subplot(1,3,1), gscatter(score1(:,1),score1(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 0-1')

[coeff2, score2, latent2] = pca(bipol_12);
subplot(1,3,2), gscatter(score2(:,1),score2(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 1-2')

[coeff3, score3, latent3] = pca(bipol_23);
subplot(1,3,3), gscatter(score3(:,1),score3(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 2-3')


%% t-SNE (t-distributed stochastic neighbor embedding, non-linear dimensionality reduction)

rng(1)
%for bp = 1:3
Y1 = tsne(bipol_01);
Y2 = tsne(bipol_12);
Y3 = tsne(bipol_23);
%end

% Plot t-SNE per bipolar offset based on normalized band power (all bands)
figure
for i = 1:10
    pt_index = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3                                           % why these dims? --> Color theory! (RGB permutations)
    scatter(Y1(pt_index,1),Y1(pt_index,2), 30, rand_clr, "filled")          % want a legend / point labels based on pt_index
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 0-1')

% gscatter(x,y,group,clr,sym,size)
% scatter(x,y,sz,c,'filled', mkr, options)

figure
for i = 1:10
    pt_index = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3                                        
    scatter(Y2(pt_index,1),Y2(pt_index,2), 30, rand_clr,"filled")
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 1-2')

figure
for i = 1:10
    pt_index = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3
    scatter(Y3(pt_index,1),Y3(pt_index,2), 30, rand_clr,"filled")
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 2-3')

%% t-SNE per bipolar offset based on normalized mean sleep-state band power (all bands) 

rng(1)
Y1_sl = tsne(bipol_01_sleep_mean);
Y2_sl = tsne(bipol_12_sleep_mean);
Y3_sl = tsne(bipol_23_sleep_mean);

figure
for pt_i = 1:10
    % pt_idx = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3                                         
    scatter(Y1_sl(pt_i,1),Y1_sl(pt_i,2), 30, rand_clr,"filled")             % want a legend / point labels based on pt_index
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 0-1, mean power during sleep')

figure
for pt_i = 1:10
    %pt_index = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3                                        
    scatter(Y2_sl(pt_i,1),Y2_sl(pt_i,2), 30, rand_clr,"filled")
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 1-2, mean power during sleep')

figure
for pt_i = 1:10
    %pt_index = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3
    scatter(Y3_sl(pt_i,1),Y3_sl(pt_i,2), 30, rand_clr,"filled")
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 2-3, mean power during sleep')


%% find other layers from data (aside from pt ID) to map back onto clusters

% 6 bands:
% 1) delta: 0-3 Hz
% 2) theta: 4-7 Hz
% 3) alpha: 8-12 Hz
% 4) low beta: 13-20 Hz
% 5) high beta: 21-30 Hz
% 6) gamma: 31-50 Hz

%% t-SNE per bipolar offset based on normalized mean sleep-state band power (beta band) 

% low beta (13-20 Hz) - col 4; high beta (21-30 Hz) - col 5
rng(1)
Y1_sl_b = tsne(bipol_01_sleep_mean(:,4:5));
Y2_sl_b = tsne(bipol_12_sleep_mean(:,4:5));
Y3_sl_b = tsne(bipol_23_sleep_mean(:,4:5));

figure
for pt_i = 1:10
    % pt_idx = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3                                         
    scatter(Y1_sl_b(pt_i,1),Y1_sl_b(pt_i,2), 30, rand_clr,"filled")             % want a legend / point labels based on pt_index
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 0-1, mean beta power during sleep')

figure
for pt_i = 1:10
    %pt_index = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3                                        
    scatter(Y2_sl_b(pt_i,1),Y2_sl_b(pt_i,2), 30, rand_clr,"filled")
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 1-2, mean beta power during sleep')

figure
for pt_i = 1:10
    %pt_index = subjectID == i; 
    rand_clr = rand(1,3); % 1 x 3
    scatter(Y3_sl_b(pt_i,1),Y3_sl_b(pt_i,2), 30, rand_clr,"filled")
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 2-3, mean beta power during sleep')

 
%% Compute cosine similarity by patient, band, and sleep stage

% review KS's cos. sim. process
    % compute cos sim against all patients per epoch based on abs. power,
    % rel., power, and ratios of power spectral bands in awake state and
    % sleep states

% LOGO model training (?)
% Ratio Testing (Lajnef et al. 2015; Thompson et al. 2018)
    % delta/theta
    % theta/alpha
    % alpha/beta
        % low beta
        % high beta
        % LF/beta
    % beta/gamma

%% Cosine similarity measures the similarity between two vectors of an inner
% product space. It is measured by the cosine of the angle between two
% vectors and determines whether two vectors are pointing in roughly the
% same direction

% similarities = cosineSimilarity(M) 
% returns similarities for the data encoded in the row vectors of the matrix M. 
% The score in similarities(i,j) represents the similarity between M(i,:) and M(j,:).

% Visualize the similarities of the first five documents in a heat map.
% figure
% heatmap(similarities(1:5,1:5));
% xlabel("Document")
% ylabel("Document")
% title("Cosine Similarities")

%% Compare
% Cs1 = getCosineSimilarity(x,y);
% Cs2 = (pdist(x,y,'cosine')) + 1;


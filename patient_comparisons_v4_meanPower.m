% Determine heterogeneity in PD patient LFP power per frequency band during sleep

% Therapeutic contact (bipol offset, biPair) per patient (xCase)
bp_ther = readtable("SleepLFP_OriginalStudy_ContactPairs.xlsx");

% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2'; % v3
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data

% extract subject ID
subjectID = []; % 8609 x 1

sl_stages = {'W','N1','N2','N3','R'}; % 5 (sleep stages)

%% Loop through patients (10) and bands (6)

bipol_ther = []; % 8609 (epochs) x 6 (bands)
bipol_ther_mean = []; % 10 (pt) x 6 (bands)                                % nan
bipol_ther_std = []; % 10 (pt) x 6 (bands)                                 % nan

for i = 1:length(summaryLFP_files) % 10 patients
    load(summaryLFP_files{i},"m", "s","sl");  % m = 1075 x 6 x 3; s = 1075 x 6 x 3; sl = 1075 x 1
    switch bp_ther.biPair{i}
        case '01'
            bipol_ther = [bipol_ther; m(:,:,1)];
            bipol_mean_temp = mean(m(:,:,1));
            bipol_std_temp = std(m(:,:,1));
        case '12'
            bipol_ther = [bipol_ther; m(:,:,2)];
            bipol_mean_temp = mean(m(:,:,2));
            bipol_std_temp = std(m(:,:,2));
        case '23'
            bipol_ther = [bipol_ther; m(:,:,3)];
            bipol_mean_temp = mean(m(:,:,3));
            bipol_std_temp = std(m(:,:,3));
    end
    bipol_ther_mean = [bipol_ther_mean; bipol_mean_temp];
    bipol_ther_std = [bipol_ther_std; bipol_std_temp];
    subjectID = [subjectID; repmat(i,length(m(:,:,1)),1)];
end


% 6 bands:
% 1) delta: 0-3 Hz
% 2) theta: 4-7 Hz
% 3) alpha: 8-12 Hz
% 4) low beta: 13-20 Hz
% 5) high beta: 21-30 Hz
% 6) gamma: 31-50 Hz

%% Determine cluster assignments based on mean LFP power
% UMAP (MatLab File Exchange)

% addpath 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\umap'

[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_ther_mean); % all bands

[reductionD, umapD, clusterIdentifiersD, extrasD] = run_umap(bipol_ther_mean(:,1)); % delta
[reductionT, umapT, clusterIdentifiersT, extrasT] = run_umap(bipol_ther_mean(:,2)); % theta
[reductionA, umapA, clusterIdentifiersA, extrasA] = run_umap(bipol_ther_mean(:,3)); % alpha
[reductionLB, umapLB, clusterIdentifiersLB, extrasLB] = run_umap(bipol_ther_mean(:,4)); % low beta
[reductionHB, umapHB, clusterIdentifiersHB, extrasHB] = run_umap(bipol_ther_mean(:,5)); % high beta
[reductionG, umapG, clusterIdentifiersG, extrasG] = run_umap(bipol_ther_mean(:,6)); % gamma

% Connor Meehan, Jonathan Ebrahimian, Wayne Moore, and Stephen Meehan
% (2022). Uniform Manifold Approximation and Projection (UMAP)
% (https://www.mathworks.com/matlabcentral/fileexchange/71902), MATLAB
% Central File Exchange.

%% PCA (linear dimensionality reduction, assessment of variance)

% Full Spectra
figure
[coeff, score, latent] = pca(bipol_ther_mean);
scatter(score(:,1),score(:,2))
%gscatter(score(:,1),score(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Therapeutic Contact, Full LFP Spectra')

%% PCA by frequency range

% Delta - Theta Range (0 - 7 Hz)*
figure
[coeffLF, scoreLF, latentLF] = pca(bipol_ther_mean(:,1:2));
scatter(scoreLF(:,1),scoreLF(:,2))
%gscatter(score(:,1),score(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Therapeutic Contact, Low Frequency Range (0-7 Hz)')

    % Alpha - Low Beta Range (8 - 20 Hz)
    figure
    [coeffMF, scoreMF, latentMF] = pca(bipol_ther_mean(:,3:4));
    scatter(scoreMF(:,1),scoreMF(:,2))
    %gscatter(score(:,1),score(:,2),subjectID)
    format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
    %legend('Cluster 1','Cluster 2', 'location', 'northwest');
    xlabel('PC1')
    ylabel('PC2')
    title('PCA, Therapeutic Contact, Alpha - Low Beta Range (8-20 Hz)')

% Beta Range (13 - 30 Hz)*
figure
[coeffB, scoreB, latentB] = pca(bipol_ther_mean(:,4:5));
scatter(scoreB(:,1),scoreB(:,2))
%gscatter(score(:,1),score(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Therapeutic Contact, Beta Range (13-30 Hz)')

    % High Beta - Gamma Range (21 - 50 Hz)
    figure
    [coeffHF, scoreHF, latentHF] = pca(bipol_ther_mean(:,5:6));
    scatter(scoreHF(:,1),scoreHF(:,2))
    %gscatter(score(:,1),score(:,2),subjectID)
    format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
    %legend('Cluster 1','Cluster 2', 'location', 'northwest');
    xlabel('PC1')
    ylabel('PC2')
    title('PCA, Therapeutic Contact, High Beta - Gamma Range (21-50 Hz)')


%% K-means (2 clusters) 
% run on PCA score#
% quant fraction of unique pt. epochs (overlap & spread)

% Full Spectra
rng(1);
X = score(:,1:2);
[idx,C] = kmeans(X,2,"Replicates",10);

figure
plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(C(:,1),C(:,2),'kx',...
    'MarkerSize',15,'LineWidth',3)
legend('Cluster 1','Cluster 2','Centroids',...
    'Location','NW')
title 'Cluster Assignments and Centroids (Full LFP Spectra)'
hold off

figure
[silh, h] = silhouette(X,idx,"sqEuclidean"); 

% determine cluster IDs
% clust1: 1,4,5,7,9
% clust2: 2,3,6,8,10

%% k-means by frequency range

% Delta - Theta Range (0 - 7 Hz)*
rng(1)
X_LF = scoreLF(:,1:2);
[idx_LF, C_LF] = kmeans(X_LF,2,"Replicates",10);

figure
plot(X_LF(idx_LF==1,1),X_LF(idx_LF==1,2),'r.','MarkerSize',12)
hold on
plot(X_LF(idx_LF==2,1),X_LF(idx_LF==2,2),'b.','MarkerSize',12)
plot(C_LF(:,1),C_LF(:,2),'kx',...
    'MarkerSize',15,'LineWidth',3)
legend('Cluster 1','Cluster 2','Centroids',...
    'Location','NW')
title 'Cluster Assignments and Centroids (LF: 0-7 Hz)'
hold off

figure
[silh_LF, h_LF] = silhouette(X_LF,idx_LF,"sqEuclidean");

% determine cluster IDs
% clust1: 2,3,5,6,8,9,10
% clust2: 1,4,7


% Beta Range (13 - 30 Hz)*
rng(1)
X_B = scoreB(:,1:2);
[idx_B, C_B] = kmeans(X_B,2,"Replicates",10);

figure
plot(X_B(idx_B==1,1),X_B(idx_B==1,2),'r.','MarkerSize',12)
hold on
plot(X_B(idx_B==2,1),X_B(idx_B==2,2),'b.','MarkerSize',12)
plot(C_B(:,1),C_B(:,2),'kx',...
    'MarkerSize',15,'LineWidth',3)
legend('Cluster 1','Cluster 2','Centroids',...
    'Location','NW')
title 'Cluster Assignments and Centroids (Beta: 13-30 Hz)'
hold off

figure
[silh_B, h_B] = silhouette(X_B,idx_B,"sqEuclidean");

% determine cluster IDs
% clust1: 1,4,5,7,9
% clust2: 2,3,6,8,10

%% take unique ptID
% all bands
% ks test
% https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test

% ex. comparison: clust1 vs. clust2 pts
% compare each stage
% sleep matrix - split subjectID by cluster ID, compare freq. bands
% awake

%% t-SNE (t-distributed stochastic neighbor embedding, non-linear dimensionality reduction)

% Full Spectra
rng(1)
Y = tsne(bipol_ther);

% Plot t-SNE based on normalized band power (all bands)
figure
for i = 1:10
    pt_index = subjectID == i;
    rand_clr = rand(1,3); % 1 x 3                                           % why these dims? --> Color theory! (RGB permutations)
    scatter(Y(pt_index,1),Y(pt_index,2), 30, rand_clr, "filled")            % want a legend / point labels based on pt_index
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, Therapeutic Contact, Full LFP Spectra')

% gscatter(x,y,group,clr,sym,size)
% scatter(x,y,sz,c,'filled', mkr, options)


%% t-SNE based on normalized mean LFP band power (all bands)

% Full Spectra
rng(1)
Y_mean = tsne(bipol_ther_mean);

figure
for pt_i = 1:10
    % pt_idx = subjectID == i;
    rand_clr = rand(1,3); % 1 x 3
    scatter(Y_mean(pt_i,1),Y_mean(pt_i,2), 30, rand_clr,"filled")           % want a legend / point labels based on pt_index
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, Therapeutic Contact, Mean LFP Power (Full Spectra)')

%% t-SNE based on normalized mean band power - LF and Beta

% LF: Delta - Theta Range (0 - 7 Hz)*
rng(1)
Y_mean_LF = tsne(bipol_ther_mean(:,1:2));
figure
for pt_i = 1:10
    % pt_idx = subjectID == i;
    rand_clr = rand(1,3); % 1 x 3
    scatter(Y_mean_LF(pt_i,1),Y_mean_LF(pt_i,2), 30, rand_clr,"filled")     % want a legend / point labels based on pt_index
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, Therapeutic Contact, Mean LF Power (0-7 Hz)')

% Beta Range (13 - 30 Hz)*
rng(1)
Y_mean_B = tsne(bipol_ther_mean(:,4:5));
figure
for pt_i = 1:10
    % pt_idx = subjectID == i;
    rand_clr = rand(1,3); % 1 x 3
    scatter(Y_mean_B(pt_i,1),Y_mean_B(pt_i,2), 30, rand_clr,"filled")       % want a legend / point labels based on pt_index
    hold on
end
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, Therapeutic Contact, Mean Beta Power (13-30 Hz)')

%% find other layers from data (aside from pt ID) to map back onto clusters

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

% Cosine similarity measures the similarity between two vectors of an inner
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

% Cs1 = getCosineSimilarity(x,y);
% Cs2 = (pdist(x,y,'cosine')) + 1;


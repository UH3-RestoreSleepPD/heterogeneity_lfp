% Determine heterogeneity in PD patient LFP band power during sleep

% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2';
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data


% separate bipolar references (create 3 big matrices)
%for bp = 1:3
bipol_01 = []; % 8609 X 6
for i = 1:length(summaryLFP_files)
    load(summaryLFP_files{i},"m")
    bipol_01 = [bipol_01; m(:,:,1)];
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

%% Determine cluster assignments
% UMAP (MatLab File Exchange)

% for bpi = 1:3
%     [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_power(bpi));
% end

[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_01);
[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_12);
[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_23);

% Connor Meehan, Jonathan Ebrahimian, Wayne Moore, and Stephen Meehan
% (2022). Uniform Manifold Approximation and Projection (UMAP)
% (https://www.mathworks.com/matlabcentral/fileexchange/71902), MATLAB
% Central File Exchange.

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

%% PCA (linear dimensionality reduction, assessment of variance)
% normalize data
% % for bp = 1:3
figure
[coeff1, score1, latent1] = pca(bipol_01);
subplot(1,3,1), gscatter(score1(:,1),score1(:,2),idx1)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 01')

[coeff2, score2, latent2] = pca(bipol_12);
subplot(1,3,2), gscatter(score2(:,1),score2(:,2),idx2)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 12')

[coeff3, score3, latent3] = pca(bipol_23);
subplot(1,3,3), gscatter(score3(:,1),score3(:,2),idx3)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 23')

% % % Biplot of PCA color coded by group idx
% % biplotG(coeff(:,1:2), score(:,1:2), 'Varlabels', Targets, 'Groups', idx)
% % xlabel('PC1')
% % ylabel('PC2')
% % title('biplot')

%% t-SNE (t-distributed stochastic neighbor embedding, non-linear dimensionality reduction)
rng(1)
%for bp = 1:3
Y1 = tsne(bipol_01);
Y2 = tsne(bipol_12);
Y3 = tsne(bipol_23);
%end

figure
subplot(1,3,1), gscatter(Y1(:,1),Y1(:,2),idx1)
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 01')
subplot(1,3,2), gscatter(Y2(:,1),Y2(:,2),idx2)
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 12')
subplot(1,3,3), gscatter(Y3(:,1),Y3(:,2),idx3)
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE, bipol 23')
 
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


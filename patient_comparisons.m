
% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2';
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data

% separate bipolar references (create 3 big matices)
% bipol_power = []; all patients' mean power per LFP epoch (# rows) per frequency band (6 columns) per bipolar offset (3)
% for bp = 1:3
% create one matrix of all patients' mean LFP power per epoch per band
bipol_idx = []; % 8609 X 6
for i = 1:length(summaryLFP_files)
    load(summaryLFP_files{i},"m")
    bipol_idx = [bipol_idx; m(:,:,1)]; 
end

% % separate bipolar references (create 3 big matrices)
% bipol_power = [];
% for bp = 1:3
%     % create one matrix of all patients' mean LFP power per epoch (# rows) per band (6 col) per bipolar offset (3)
%     bipol_idx = []; % 8609 X 6 
%     for i = 1:length(summaryLFP_files)
%         load(summaryLFP_files{i},"m")
%         bipol_idx = [bipol_idx; m(:,:,bp)];
%     end
%     bipol_power = [m(:,:,1), m(:,:,2), m(:,:,3)]
% end

% rows (observations) = # patients (10) * # epochs per patient
% cols_h (features) =  # bands (6)
% cols_d (contact combinations) = bipolar offsets (3)

%% rows of sl that are only sleep states: vector logical of sl

sl_logical = []; % 1075 x 1
for j = 1:length(sl)
    % rows of sl that are only sleep states: vector logical of sl
    if sl{j} == 'N1', 'N2', 'N3', 'R'
        sl_logical(j) = 1;
    elseif sl{j} == 'W'
        sl_logical(j) = 0;
    end
end
sl_logical = sl_logical';

%% Determine cluster assignments
%% UMAP (MatLab File Exchange)

[reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_idx);

% Connor Meehan, Jonathan Ebrahimian, Wayne Moore, and Stephen Meehan
% (2022). Uniform Manifold Approximation and Projection (UMAP)
% (https://www.mathworks.com/matlabcentral/fileexchange/71902), MATLAB
% Central File Exchange.

%% k-means clustering (2)
rng(1);
[idx,C] = kmeans(bipol_idx,2);

rng(1)
figure, funcPlot(bipol_idx,C,idx)

figure 
[silh,h] = silhouette(bipol_idx,idx,"sqEuclidean");

%% PCA (linear dimensionality reduction, assessment of variance)
% % normalize data
[coeff, score, latent] = pca(bipol_idx);
figure, gscatter(score(:,1),score(:,2),idx)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA')

% % Biplot of PCA color coded by group idx
% biplotG(coeff(:,1:2), score(:,1:2), 'Varlabels', Targets, 'Groups', idx)
% xlabel('PC1')
% ylabel('PC2')
% title('biplot')
 
%% t-SNE (t-distributed stochastic neighbor embedding, non-linear dimensionality reduction)
rng(1)
Y = tsne(bipol_idx);
figure, gscatter(Y(:,1),Y(:,2),idx)
legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('Dim1')
ylabel('Dim2')
title('t-SNE')
 
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



% 1. read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2';

summaryLFP_files = {'summaryLFP_Minn_01','summaryLFP_Minn_02',...
    'summaryLFP_Minn_03', 'summaryLFP_Minn_04', 'summaryLFP_Minn_05',...
    'summaryLFP_Minn_06', 'summaryLFP_Minn_07', 'summaryLFP_Minn_08',...
    'summaryLFP_Minn_09', 'summaryLFP_Minn_10'};

load("summaryLFP_Minn_01.mat","m","s","sl");
% ...
load("summaryLFP_Minn_10.mat","m","s","sl");

% 2. Devide patient outputs by power spectral band

% 3. Compare mean power per band per patient and per pt. sleep state

% rows (observations) = # patients (10) * min # of patient epochs (~650 epochs per patient, psuedo-randomly sampled)
% cols (features) =  # bands (6) * # states (4) 
% 4 sleep states: awake, REM, N1, N2 (forget N3)

% 4. Psuedo-randomly sample 650 epochs from each patient (650*10 row observations)

% 5. Structure power data by band and sleep state (6 * 4 columns)

% 6. Compute absolute power per band per sleep state per patient epoch 

% 7. Determine cluster assignments
% PCA
% t-SNE --> determine clusters (2)

% Compare absolute power distributions between clusters
% Compute cos. sim 



%% Compute cosine similarity by patient, band, and sleep stage

% review KS's cosine sim. process
    % compute cos sim against all patients per epoch based on abs. power,
    % rel., power, and ratios of power spectral bands in awake state and
    % sleep states'

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

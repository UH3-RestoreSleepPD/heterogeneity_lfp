% Determine heterogeneity in PD patient LFP power per frequency band during sleep

% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2'; % v3
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data

% extract subject ID
subjectID = []; % 8609 x 1

% separate bipolar contacts (create 3 big matrices)
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
    sl_logical = zeros(length(sl),1,'logical'); % 1075 x 1                  % nans
    for j = 1:length(sl)
        if matches(sl{j},{'N1', 'N2', 'N3', 'R'}) % matches replaces strcmp
            sl_logical(j) = true; % sl{j} = 1; else 'W', sl{j} = 0
        end
    end
    bipol_01_sleep_temp = mean(m(sl_logical,:,1));                          % omit nan
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

% 6 bands:
% delta: 0-3 Hz
% theta: 4-7 Hz
% alpha: 8-12 Hz
% beta: 13-30 Hz
%   low beta: 13-20 Hz
%   high beta: 21-30 Hz
% gamma: 31-50 Hz (cut gamma off at 50)

%% Determine cluster assignments
% UMAP (MatLab File Exchange)

% addpath 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\umap'

% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_01);
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_12);
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_23);
% 
% % mean sleep (all bands)
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_01_sleep_mean);
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_12_sleep_mean);
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_23_sleep_mean);
% 
% % mean sleep (low beta)
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_01_sleep_mean(:,4));
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_12_sleep_mean(:,4));
% [reduction, umap, clusterIdentifiers, extras] = run_umap(bipol_23_sleep_mean(:,4));


% Connor Meehan, Jonathan Ebrahimian, Wayne Moore, and Stephen Meehan
% (2022). Uniform Manifold Approximation and Projection (UMAP)
% (https://www.mathworks.com/matlabcentral/fileexchange/71902), MATLAB
% Central File Exchange.

%% PCA (linear dimensionality reduction, assessment of variance)
% normalize data (?)
% for bp = 1:3

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


%% PCA per bipolar offset (beta)

figure
[coeff1_b, score1_b, latent1_b] = pca(bipol_01(:,4:5));
subplot(1,3,1), gscatter(score1_b(:,1),score1_b(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 0-1 (beta)')

[coeff2_b, score2_b, latent2_b] = pca(bipol_12(:,4:5));
subplot(1,3,2), gscatter(score2_b(:,1),score2_b(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 1-2 (beta)')

[coeff3_b, score3_b, latent3_b] = pca(bipol_23(:,4:5));
subplot(1,3,3), gscatter(score3_b(:,1),score3_b(:,2),subjectID)
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, bipol 2-3 (beta)')

%% PCA per bipolar offset based on normalized mean sleep-state band power (all bands) 

figure
[coeff1_sm, score1_sm, latent1_sm] = pca(bipol_01_sleep_mean);
subplot(1,3,1), scatter(score1_sm(:,1),score1_sm(:,2))
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Sleep Mean, bipol 0-1')

[coeff2_sm, score2_sm, latent2_sm] = pca(bipol_12_sleep_mean);
subplot(1,3,2), scatter(score2_sm(:,1),score2_sm(:,2))
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Sleep Mean, bipol 1-2')

[coeff3_sm, score3_sm, latent3_sm] = pca(bipol_23_sleep_mean);
subplot(1,3,3), scatter(score3_sm(:,1),score3_sm(:,2))
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Sleep Mean, bipol 2-3')

%% PCA per bipolar offset based on normalized mean sleep-state band power (beta)

figure
[coeff1_sm_b, score1_sm_b, latent1_sm_b] = pca(bipol_01_sleep_mean(:,4:5));
subplot(1,3,1), scatter(score1_sm_b(:,1),score1_sm_b(:,2))
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Sleep Mean (beta), bipol 0-1')

[coeff2_sm_b, score2_sm_b, latent2_sm_b] = pca(bipol_12_sleep_mean(:,4:5));
subplot(1,3,2), scatter(score2_sm_b(:,1),score2_sm_b(:,2))
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Sleep Mean (beta), bipol 1-2')

[coeff3_sm_b, score3_sm_b, latent3_sm_b] = pca(bipol_23_sleep_mean(:,4:5));
subplot(1,3,3), scatter(score3_sm_b(:,1),score3_sm_b(:,2))
format = { {}; {'Marker', '^', 'MarkerSize', 6}; {}};
%legend('Cluster 1','Cluster 2', 'location', 'northwest');
xlabel('PC1')
ylabel('PC2')
title('PCA, Sleep Mean (beta), bipol 2-3')

%% K means (2 clusters) per bipolar offset (all bands)
% run on PCA score#
% determine cluster IDs 
% quant fraction of unique pt. epochs (overlap & spread)

% bipol 0-1
rng(1);
X1 = score1(:,1:2);
[idx1,C1] = kmeans(X1,2,"Replicates",10);
C1_bp01 = unique(subjectID(idx1 == 1))
C2_bp01 = unique(subjectID(idx1 == 2))

figure
plot(X1(idx1==1,1),X1(idx1==1,2),'r.','MarkerSize',12)
hold on
plot(X1(idx1==2,1),X1(idx1==2,2),'b.','MarkerSize',12)
plot(C1(:,1),C1(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (bipol 0-1)'
hold off

figure 
[silh1, h1] = silhouette(X1,idx1,"sqEuclidean");

% bp01
% clust1: all patients (Pt. 1-10)
% clust2: Pt. 2,3,6,8,9,10


% bipol 1-2
rng(1);
X2 = score2(:,1:2);
[idx2,C2] = kmeans(X2,2,"Replicates",10);
C1_bp12 = unique(subjectID(idx2 == 1))
C2_bp12 = unique(subjectID(idx2 == 2))

figure
plot(X2(idx2==1,1),X2(idx2==1,2),'r.','MarkerSize',12)
hold on
plot(X2(idx2==2,1),X2(idx2==2,2),'b.','MarkerSize',12)
plot(C2(:,1),C2(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (bipol 1-2)'
hold off

figure 
[silh2, h2] = silhouette(X2,idx2,"sqEuclidean");

% bp12
% clust1: all patients (Pt. 1-10)
% clust2: Pt. 2,3,4,5,6,8,9,10


% bipol 2-3
rng(1);
X3 = score3(:,1:2);
[idx3,C3] = kmeans(X3,2,"Replicates",10);
C1_bp23 = unique(subjectID(idx3 == 1))
C2_bp23 = unique(subjectID(idx3 == 2))

figure
plot(X3(idx3==1,1),X3(idx3==1,2),'r.','MarkerSize',12)
hold on
plot(X3(idx3==2,1),X3(idx3==2,2),'b.','MarkerSize',12)
plot(C3(:,1),C3(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (bipol 2-3)'
hold off

figure 
[silh3, h3] = silhouette(X3,idx3,"sqEuclidean");

% bp23
% clust1: all patients (Pt. 1-10)
% clust2: Pt. 2,3,4,5,6,7,8,9,10


% "Average Relative Power for awake states averaged throughout the night 
% average across the found groups [0,4,8] (gr 1), [2,3,6,7] (gr 2) 
% and [1,5] (grnother)."


%% K means (2 clusters) per bipolar offset (beta)
% bipol 0-1
rng(1);
X1_b = score1_b(:,1:2);
[idx1_b,C1_b] = kmeans(X1_b,2,"Replicates",10);
C1_bp01_b = unique(subjectID(idx1_b == 1))
C2_bp01_b = unique(subjectID(idx1_b == 2))

figure
plot(X1_b(idx1_b==1,1),X1_b(idx1_b==1,2),'r.','MarkerSize',12)
hold on
plot(X1_b(idx1_b==2,1),X1_b(idx1_b==2,2),'b.','MarkerSize',12)
plot(C1_b(:,1),C1_b(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (bipol 0-1, beta)'
hold off

figure 
[silh1_b, h1_b] = silhouette(X1_b,idx1_b,"sqEuclidean");

% bp01 b
% clust1: all patients (Pt. 1-10)
% clust2: all patients (Pt. 1-10)


% bipol 1-2
rng(1);
X2_b = score2_b(:,1:2);
[idx2_b,C2_b] = kmeans(X2_b,2,"Replicates",10);
C1_bp12_b = unique(subjectID(idx2_b == 1))
C2_bp12_b = unique(subjectID(idx2_b == 2))

figure
plot(X2_b(idx2_b==1,1),X2_b(idx2_b==1,2),'r.','MarkerSize',12)
hold on
plot(X2_b(idx2_b==2,1),X2_b(idx2_b==2,2),'b.','MarkerSize',12)
plot(C2_b(:,1),C2_b(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (bipol 1-2, beta)'
hold off

figure 
[silh2_b, h2_b] = silhouette(X2_b,idx2_b,"sqEuclidean");

% bp12 b
% clust1: all patients (Pt. 1-10)
% clust2: all patients (Pt. 1-10)


% bipol 2-3
rng(1);
X3_b = score3_b(:,1:2);
[idx3_b,C3_b] = kmeans(X3_b,2,"Replicates",10);
C1_bp23_b = unique(subjectID(idx3_b == 1))
C2_bp23_b = unique(subjectID(idx3_b == 2))

figure
plot(X3_b(idx3_b==1,1),X3_b(idx3_b==1,2),'r.','MarkerSize',12)
hold on
plot(X3_b(idx3_b==2,1),X3_b(idx3_b==2,2),'b.','MarkerSize',12)
plot(C3_b(:,1),C3_b(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (bipol 2-3, beta)'
hold off

figure 
[silh3_b, h3_b] = silhouette(X3_b,idx3_b,"sqEuclidean");

% bp23
% clust1: all patients (Pt. 1-10)
% clust2: all patients (Pt. 1-10)


%% K means (2 clusters) - per bipolar offset based on normalized mean sleep-state band power (all bands) 
% run on PCA score#
% determine cluster IDs 
% quant fraction of unique pt. epochs (overlap & spread)

% bipol 0-1
rng(1);
X1_sm = score1_sm(:,1:2);
[idx1_sm,C1_sm] = kmeans(X1_sm,2,"Replicates",10);

figure
plot(X1_sm(idx1_sm==1,1),X1_sm(idx1_sm==1,2),'r.','MarkerSize',12)
hold on
plot(X1_sm(idx1_sm==2,1),X1_sm(idx1_sm==2,2),'b.','MarkerSize',12)
plot(C1_sm(:,1),C1_sm(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (Sleep Mean, bipol 0-1)'
hold off

figure 
[silh1_sm, h1_sm] = silhouette(X1_sm,idx1_sm,"sqEuclidean");

% bp01
% clust1: 1,3,4,5,7,
% clust2: 2,6,8,9,10


% bipol 1-2
rng(1);
X2_sm = score2_sm(:,1:2);
[idx2_sm,C2_sm] = kmeans(X2_sm,2,"Replicates",10);

figure
plot(X2_sm(idx2_sm==1,1),X2_sm(idx2_sm==1,2),'r.','MarkerSize',12)
hold on
plot(X2_sm(idx2_sm==2,1),X2_sm(idx2_sm==2,2),'b.','MarkerSize',12)
plot(C2_sm(:,1),C2_sm(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (Sleep Mean, bipol 1-2)'
hold off

figure 
[silh2_sm, h2_sm] = silhouette(X2_sm,idx2_sm,"sqEuclidean");

% bp12
% clust1: 2,3,4,5,6,8,9,10
% clust2: 1,7
 

% bipol 2-3
rng(1);
X3_sm = score3_sm(:,1:2);
[idx3_sm,C3_sm] = kmeans(X3_sm,2,"Replicates",10);

figure
plot(X3_sm(idx3_sm==1,1),X3_sm(idx3_sm==1,2),'r.','MarkerSize',12)
hold on
plot(X3_sm(idx3_sm==2,1),X3_sm(idx3_sm==2,2),'b.','MarkerSize',12)
plot(C3_sm(:,1),C3_sm(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (Sleep Mean, bipol 2-3)'
hold off

figure 
[silh3_sm, h3_sm] = silhouette(X3_sm,idx3_sm,"sqEuclidean");

% bp12
% clust1: 2,3,6,7,8,9,10
% clust2: 1,4,5


%% K means (2 clusters) - per bipolar offset based on normalized mean sleep-state band power (beta) 
% run on PCA score#
% determine cluster IDs 
% quant fraction of unique pt. epochs (overlap & spread)

% bipol 0-1
rng(1);
X1_sm_b = score1_sm_b(:,1:2);
[idx1_sm_b,C1_sm_b] = kmeans(X1_sm_b,2,"Replicates",10);

figure
plot(X1_sm_b(idx1_sm_b==1,1),X1_sm_b(idx1_sm_b==1,2),'r.','MarkerSize',12)
hold on
plot(X1_sm_b(idx1_sm_b==2,1),X1_sm_b(idx1_sm_b==2,2),'b.','MarkerSize',12)
plot(C1_sm_b(:,1),C1_sm_b(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (Sleep Mean (beta), bipol 0-1)'
hold off

figure 
[silh1_sm_b, h1_sm_b] = silhouette(X1_sm_b,idx1_sm_b,"sqEuclidean");

% bp01 b
% clust1: 1,3,4,5,7
% clust2: 2,6,8,9,10


% bipol 1-2
rng(1);
X2_sm_b = score2_sm_b(:,1:2);
[idx2_sm_b,C2_sm_b] = kmeans(X2_sm_b,2,"Replicates",10);

figure
plot(X2_sm_b(idx2_sm_b==1,1),X2_sm_b(idx2_sm_b==1,2),'r.','MarkerSize',12)
hold on
plot(X2_sm_b(idx2_sm_b==2,1),X2_sm_b(idx2_sm_b==2,2),'b.','MarkerSize',12)
plot(C2_sm_b(:,1),C2_sm_b(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (Sleep Mean (beta), bipol 1-2)'
hold off

figure 
[silh2_sm_b, h2_sm_b] = silhouette(X2_sm_b,idx2_sm_b,"sqEuclidean");

% bp12 b
% clust1: 2,3,4,5,6,8,9,10
% clust2: 1,7
 

% bipol 2-3
rng(1);
X3_sm_b = score3_sm_b(:,1:2);
[idx3_sm_b,C3_sm_b] = kmeans(X3_sm_b,2,"Replicates",10);

figure
plot(X3_sm_b(idx3_sm_b==1,1),X3_sm_b(idx3_sm_b==1,2),'r.','MarkerSize',12)
hold on
plot(X3_sm_b(idx3_sm_b==2,1),X3_sm_b(idx3_sm_b==2,2),'b.','MarkerSize',12)
plot(C3_sm_b(:,1),C3_sm_b(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids (Sleep Mean (beta), bipol 2-3)'
hold off

figure 
[silh3_sm_b, h3_sm_b] = silhouette(X3_sm_b,idx3_sm_b,"sqEuclidean");

% bp12 b
% clust1: 2,3,6,7,8,9,10
% clust2: 1,4,5

%% take unique ptID
% all bands
% ks test
% https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test

% ex. comparison: clust1 vs. clust2 pts
% compare each stage
% sleep matrix - split subjectID by cluster ID, compare freq. bands
% awake

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


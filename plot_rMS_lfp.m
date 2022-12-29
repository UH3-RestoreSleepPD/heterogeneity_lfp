function [] = plot_rMS_lfp(testfile,dataDir)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

cd(dataDir)
load(testfile,'bpRMSz','sln');
bpRMSz2 = normalize(bpRMSz,'zscore');
D = pdist(bpRMSz2,'euclidean');
Y = cmdscale(D);

cmaPP = [0 0.4470 0.7410;
    0.8500 0.3250 0.0980;
    0.9290 0.6940 0.1250];

allColos = zeros(height(bpRMSz2),3);
for ssi = 1:length(sln{1,1})

    switch sln{1,1}{ssi}
        case {'N1','N2','N3'}
            allColos(ssi,:) = cmaPP(1,:);

        case {'R'}
            allColos(ssi,:) = cmaPP(2,:);

        case {'W'}
           allColos(ssi,:) = cmaPP(3,:);

    end
end

scatter(Y(:,1),Y(:,2),30,allColos,'filled');






end
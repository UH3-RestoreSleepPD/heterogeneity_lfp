function [] = plot_rMS_lfp_v2(testfile,dataDir)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

cd(dataDir)
load(testfile,'bpRMSzT','sln3','mdsParms');

cmaPP = [0 0.4470 0.7410;
    0.8500 0.3250 0.0980;
    0.9290 0.6940 0.1250];

allColos = zeros(height(bpRMSzT),3);
for ssi = 1:height(sln3)

    switch sln3{ssi}
        case {'N1','N2','N3'}
            allColos(ssi,:) = cmaPP(1,:);

        case {'R'}
            allColos(ssi,:) = cmaPP(2,:);

        case {'W'}
           allColos(ssi,:) = cmaPP(3,:);

    end
end

% scatter(mdsParms(:,1),mdsParms(:,2),30,allColos,'filled');
% scatter3(mdsParms(:,1),mdsParms(:,2),mdsParms(:,3),30,allColos,'filled');

nremMean = mean(mdsParms(matches(sln3,{'N1','N2','N3'}),:));
remMean = mean(mdsParms(matches(sln3,{'R'}),:));
awakeMean = mean(mdsParms(matches(sln3,{'W'}),:));
allMeans = [nremMean ; remMean ; awakeMean];

nremstd = std(mdsParms(matches(sln3,{'N1','N2','N3'}),:));
remstd = std(mdsParms(matches(sln3,{'R'}),:));
awakestd = std(mdsParms(matches(sln3,{'W'}),:));
allstds = [nremstd ; remstd ; awakestd];

for poinTT = 1:3
    for axiSS = 1:3

        allstdsZZ = zeros(1,3);
        allstdsZZ(axiSS) = allstds(poinTT,1);
        pointp = allMeans(poinTT,:) + allstdsZZ;
        pointn = allMeans(poinTT,:) - allstdsZZ;

        pointall = [pointp ; pointn];
        hold on
        plot3(pointall(:,1),pointall(:,2),pointall(:,3),'Color',cmaPP(poinTT,:))

    end

end

scatter3(allMeans(:,1),allMeans(:,2),allMeans(:,3),60,cmaPP,'filled');
view([135 42])
legend('NREM','','','REM','','','AWAKE')





end
% Jat locations


curname = getenv('COMPUTERNAME');

switch curname
    case 'DESKTOP-FAGRV5G' % home pc

        maindir.data = 'D:\LFP_HG_Radcliffe\rawLFP';
        maindir.save = 'D:\LFP_HG_Radcliffe\procLFP';
        maindir.github = 'C:\Users\Admin\Documents\Github\heterogeneity_lfp';
        maindir.procData = 'D:\LFP_HG_Radcliffe\procLFP';

    case 'blah'

end

cd(maindir.data)
matList = dir("*.mat");
matList1 = {matList.name};

% Functions of interest
% summaryLFPfun_jat
% summaryLFPfun_jat(matList1, maindir.data, maindir.save)
% quantify_sleepLFPfun_jat

% 1. load and process raw data
%%
cd(maindir.procData)
testfile = 'summaryLFP_2_UMin_1_LFPraw.mat';
load(testfile);


%% 1 get first epoch

for epi = 1:height(bipolarS)

    epoch1 = [bipolarS{epi,:}]; % seconds
    fs = 1024;
    binWidth = 5; % seconds
    binStep = 2; % seconds
    numBins = 0:binStep:30;
    maxSamps = 1024*30;
    binStart = [1 , (numBins(2:end-1)*fs)+1];
    binEnd = binStart + (binWidth*fs);
    binEnd(binEnd > 30*fs) = 30*fs;

    epochMat = zeros(length(binEnd),3);
    for bi = 1:3
        tmpB = epoch1(:,bi);
        for ei = 1:length(binStart)
            tmpBin = tmpB(binStart(ei):binEnd(ei),:);
            tmpRMS = rms(tmpBin);
            epochMat(ei,bi) = tmpRMS;
        end
    end
%     epochRMSnorm = normalize(epoch1,'zscore');
    D = pdist(epochMat,'euclidean');
    Y = cmdscale(D);
    Y2 = mean(Y);


    switch sl{epi}
        case {'N1','N2'}
            colo2u = 'g';

        case {'R'}
            colo2u = 'r';

        case {'W'}
            colo2u = 'k';

    end
    plot(Y2(:,1),Y2(:,2),'Color',colo2u,'LineWidth',1);
    hold on
    plot(Y2(:,1),Y2(:,2),'Color',colo2u,'LineStyle','none','Marker','o',...
        'MarkerFaceColor',colo2u);

%     pause

end

%%

for epi = 1:height(powerNM{1,1})

    epoch1 = [powerNM{1,1}{epi},powerNM{1,2}{epi},powerNM{1,3}{epi}]; % seconds

    epochTdecSm = zeros(ceil(4096/10),3);
    for bd = 1:3
        tmpBD = decimate(epoch1(:,bd),10);
        tmpSM = smoothdata(tmpBD,'gaussian',30);
        epochTdecSm(:,bd) = tmpSM;
    end

%     fs = 1024;
%     binWidth = 5; % seconds
%     binStep = 2; % seconds
%     numBins = 0:binStep:30;
%     maxSamps = 1024*30;
%     binStart = [1 , (numBins(2:end-1)*fs)+1];
%     binEnd = binStart + (binWidth*fs);
%     binEnd(binEnd > 30*fs) = 30*fs;
% 
%     epochMat = zeros(length(binEnd),3);
%     for bi = 1:3
%         tmpB = epoch1(:,bi);
%         for ei = 1:length(binStart)
%             tmpBin = tmpB(binStart(ei):binEnd(ei),:);
%             tmpRMS = rms(tmpBin);
%             epochMat(ei,bi) = tmpRMS;
%         end
%     end
    epochRMSnorm = normalize(epochTdecSm,'zscore');
    D = pdist(epochRMSnorm,'euclidean');
    Y = cmdscale(D);
    Y2 = mean(Y);


    switch sl{epi}
        case {'N1','N2'}
            colo2u = 'g';

        case {'R'}
            colo2u = 'r';

        case {'W'}
            colo2u = 'k';

    end
    plot(Y2(:,1),Y2(:,2),'Color',colo2u,'LineWidth',1);
    hold on
    plot(Y2(:,1),Y2(:,2),'Color',colo2u,'LineStyle','none','Marker','o',...
        'MarkerFaceColor',colo2u);

%     pause

end

%%
epochDS = zeros(103,height(powerNM{1,1}));
for spii = 1:height(powerNM{1,1})

    epoch1 = [powerNM{1,1}{spii},powerNM{1,2}{spii},powerNM{1,3}{spii}]; % seconds

    epochTdecSm = zeros(ceil(4096/40),3);
    for bd = 1:3
        tmpBD = decimate(epoch1(:,bd),40);
        tmpSM = smoothdata(tmpBD,'gaussian',30);
        epochTdecSm(:,bd) = tmpSM;
    end

    epochDS(:,spii) = mean(epochTdecSm,2);

    D = pdist(epochTdecSm,'euclidean');
    Y = cmdscale(D);
    Y2 = mean(Y);

    switch sl{1}{spii}
        case {'N1','N2'}
            colo2u = 'g';
            subplot(1,4,1)
            hold on
            plot(mean(epochTdecSm,2),'Color',colo2u)
            ylim([0 0.8])


        case {'R'}
            colo2u = 'r';
                        subplot(1,4,2)
            hold on
            plot(mean(epochTdecSm,2),'Color',colo2u)
                        ylim([0 0.8])

        case {'W'}
            colo2u = 'k';
                        subplot(1,4,3)
            hold on
            plot(mean(epochTdecSm,2),'Color',colo2u)
                        ylim([0 0.8])

    end



    switch sl{1}{spii}
        case {'N1','N2'}
            colo2u = 'g';

        case {'R'}
            colo2u = 'r';

        case {'W'}
            colo2u = 'k';

    end
    subplot(1,4,4)

    hold on
        plot(Y2(:,1),Y2(:,2),'Color',colo2u,'LineStyle','none','Marker','o',...
            'MarkerFaceColor',colo2u);
end

%%

wakeMean = mean(epochDS(:,matches(sl{1},'W')),2);
nremMean = mean(epochDS(:,matches(sl{1},{'N1','N2'})),2);
remMean = mean(epochDS(:,matches(sl{1},{'R'})),2);

subplot(1,2,1)
plot(wakeMean); hold on; plot(nremMean); plot(remMean); legend('W','N','R')
xlim([0 100])
ylabel('Scaled power')

WvR = dtw(wakeMean,remMean);
WvN = dtw(wakeMean,nremMean);
RvN = dtw(remMean,nremMean);

subplot(1,2,2)
cmaPP = [0 0.4470 0.7410;
    0.8500 0.3250 0.0980;
    0.9290 0.6940 0.1250];
scatter(ones(1,3),[WvR,WvN,RvN],50,cmaPP,'filled')
text(1.25,WvR,['WvR ',num2str(round(WvR,2))],'Color',cmaPP(1,:))
text(1.25,WvN,['WvN ',num2str(round(WvN,2))],'Color',cmaPP(2,:))
text(1.25,RvN,['RvN ',num2str(round(RvN,2))],'Color',cmaPP(3,:))
xlim([0.25 2])
xticks([])
ylabel('DTW Euclidean distance')

%% TO do 12/28
% 1. Determine bipolar contribution to above

% 2. Determine subject offset to above

% 3. recreate frontiers image regarding full night recording

    
% [R,P] = corrcoef(epochDS(:,1:10));
% [R,P] = corrcoef(epochDS(:,1),epochDS(:,223));
% [R,P] = corrcoef(epochDS(:,1),epochDS(:,10));
% [R,P] = corrcoef(epochDS(:,215),epochDS(:,223));
% [R,P] = corrcoef(epochDS(:,215),epochDS(:,1072));
% [R,P] = corrcoef(epochDS(:,10),epochDS(:,1072));
% 
% 
% [R] = dtw(epochDS(:,215),epochDS(:,1072))
% [R] = dtw(epochDS(:,1),epochDS(:,223));
% [R] = dtw(epochDS(:,1),epochDS(:,10));
% [R] = dtw(epochDS(:,215),epochDS(:,223));
% [R] = dtw(epochDS(:,215),epochDS(:,1072));
% [R] = dtw(epochDS(:,10),epochDS(:,1072));
% 
% epochDS2 = epochDS;
% epochDS2 = epochDS2(:,[1:921,923:width(epochDS2)]);
% sl2 = sl([1:921,923:width(epochDS)])

%%
dtwAll = zeros(width(epochDS));
for dtI = 1:width(epochDS)

    tmpEd = epochDS(:,dtI);

    for dtI2 = 1:width(epochDS)

        dtwAll(dtI,dtI2) = dtw(epochDS(:,dtI),epochDS(:,dtI2));
        disp(['row ' , num2str(dtI) , ' col ', num2str(dtI2) ])

    end
end



% plot(Y(:,1),Y(:,2),'k-',Y(:,1),Y(:,2),'rx')
% DTW on power

% 2. explore raw similaritie - cross cor time series (dtw?) cluster time
% series

% 3. hierarchal cluster by band / sleep stage , 1) raw trace 2) average
% power

% 4. Tsne / umap

% 5. pca

% 6. lda / demixed pca





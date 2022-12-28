function [] = plot_Sleep_DTW(maindir,testfile)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


cd(maindir)
load(testfile,'powerNM','sl');

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
end


wakeMean = mean(epochDS(:,matches(sl{1},'W')),2);
nremMean = mean(epochDS(:,matches(sl{1},{'N1','N2'})),2);
remMean = mean(epochDS(:,matches(sl{1},{'R'})),2);

figure;
subplot(1,2,1)
if sum(~isnan(remMean)) == 0
    plot(wakeMean); hold on; plot(nremMean); legend('W','N')
    xlim([0 100])
    ylabel('Scaled power')

%     WvR = dtw(wakeMean,remMean);
    WvN = dtw(wakeMean,nremMean);
%     RvN = dtw(remMean,nremMean);

    subplot(1,2,2)
    cmaPP = [0 0.4470 0.7410;
        0.8500 0.3250 0.0980;
        0.9290 0.6940 0.1250];
    scatter(ones(1,1),WvN,50,cmaPP(2,:),'filled')
%     text(1.25,WvR,['WvR ',num2str(round(WvR,2))],'Color',cmaPP(1,:))
    text(1.25,WvN,['WvN ',num2str(round(WvN,2))],'Color',cmaPP(2,:))
%     text(1.25,RvN,['RvN ',num2str(round(RvN,2))],'Color',cmaPP(3,:))
    xlim([0.25 2])
    xticks([])
    ylabel('DTW Euclidean distance')
else
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
end



end
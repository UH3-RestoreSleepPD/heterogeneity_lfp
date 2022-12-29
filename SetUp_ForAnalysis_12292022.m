% Script for ER to run LFP heterogeneity analyses

% Current computer name
curname = getenv('COMPUTERNAME');

switch curname
    case 'DESKTOP-FAGRV5G' % home pc

        maindir.data = 'D:\LFP_HG_Radcliffe\rawLFP';
        maindir.save = 'D:\LFP_HG_Radcliffe\procLFP';
        maindir.github = 'C:\Users\Admin\Documents\Github\heterogeneity_lfp';
        maindir.procData = 'D:\LFP_HG_Radcliffe\procLFP';
        maindir.rmsData = 'D:\LFP_HG_Radcliffe\NrmsLFP';
        maindir.NrmsData = 'D:\LFP_HG_Radcliffe\zRMSlfp';

    case 'OTHER PC' % Erin add your computer name and directory locations [data is on box]

end


%% STEP 1 - Create raw files of Power spectrum and epochs [DONE]

cd(maindir.data)
matList = dir("*.mat");
matList1 = {matList.name};
summaryLFPfun_jat(matList1, maindir.data, maindir.save)

%% STEP 2 - Generate DTW analysis visualization for PSD plots by sleep stage [TO DO]
% To do: quantitative/statistical analysis of results

plot_Sleep_DTW(maindir.procData,'summaryLFP_10_UMin_1_LFPraw.mat')

%% STEP 3 - Generate initial RMS results from raw epochs [DONE]
cd(maindir.procData)
dirs2use.rawDir = maindir.procData;
dirs2use.saveDir = maindir.rmsData;

mat2use1 = dir('*.mat');
mat2use2 = {mat2use1.name};

for ci = 1:length(mat2use2)
    tmpfname = mat2use2{ci};
    createRMS_LFP(tmpfname,dirs2use)
end

%% STEP 4 - Clean up RMS and z-score [DONE]
cd(maindir.rmsData)
dirs2use.rawDir = maindir.rmsData;
dirs2use.saveDir = maindir.NrmsData;

mat2use1 = dir('*.mat');
mat2use2 = {mat2use1.name};

for ci = 1:length(mat2use2)
    tmpfname = mat2use2{ci};
    clean_rMS_lfp(tmpfname,dirs2use)
end

%% STEP 5 - Plot MEAN and STD of Multidimensional scaled epoch data by sleep stage [TO DO]
close all
testfile = 'ZSrmsLFP_9_UMin_1.mat';
dataDir = maindir.NrmsData;
plot_rMS_lfp_v2(testfile,dataDir)








function [] = summaryLFPfun_jat(patient_files, dataDIR, saveDIR)

% patient_files = {'10_UMin_1_LFPraw.mat'};


% patient_files = {'2_UMin_1_LFPraw.mat',...
%    '3_UMin_1_LFPraw.mat', '4_UMin_1_LFPraw.mat', '5_UMin_1_LFPraw.mat',...
%    '6_UMin_1_LFPraw.mat', '7_UMin_1_LFPraw.mat'};


% create main directory and folder/directory for LFP summary outputs
% maindir = 'C:\Users\Admin\Downloads\MINNLFP'; % DAS
% savedir = 'C:\Users\Admin\Downloads\tabForm';

cd(dataDIR)  % cd = change directory

for i = 1:length(patient_files)
    % create patient dir
    cd(dataDIR)

    % run function on all patient files
    [m,s,sl,bipolarS, powerNM] = quantify_sleepLFPfun_jat_V2(patient_files{i});

    % save outputs in new folder
    patINFO = split(patient_files{i},'.');
    savename = ['summaryLFP_',patINFO{1},'.mat'];
    cd(saveDIR);
    save(savename,'m','s','sl','bipolarS','powerNM');
end

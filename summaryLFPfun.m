%% Script that runs all patient data through quantify_sleepLFPfun and saves outputs in new folder

patient_files = {'1_UMin_1_LFPraw.mat','2_UMin_1_LFPraw.mat',...
    '3_UMin_1_LFPraw.mat', '4_UMin_1_LFPraw.mat', '5_UMin_1_LFPraw.mat',...
   '6_UMin_1_LFPraw.mat', '7_UMin_1_LFPraw.mat','8_UMin_1_LFPraw.mat',...
   '9_UMin_1_LFPraw.mat','10_UMin_1_LFPraw.mat'};

% create main directory and folder/directory for LFP summary outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\RawPSG_Tableformat';
savedir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP';

cd(maindir)  % cd = change directory
folder1 = dir;   
folder2 = {folder1.name};
folder3 = folder2(~ismember(folder2,{'.','..'}));

for i = 1:length(folder3)
    % create patient dir
    temp_patientdir = [maindir,filesep,folder3{i}];
    cd(temp_patientdir);

    % run function on all patient files
    [m,s] = quantify_sleepLFPfun(patient_files{i});

    % save outputs in new folder
    savename = ['summaryLFP_',folder3{i},'.mat'];
    cd(savedir);
    save(savename,'m','s');
end
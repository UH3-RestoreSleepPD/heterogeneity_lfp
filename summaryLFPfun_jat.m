%% Script that runs all patient data through quantify_sleepLFPfun and saves outputs in new folder

% patient_files = {'1_UMin_1_LFPraw.mat','2_UMin_1_LFPraw.mat',...
%     '3_UMin_1_LFPraw.mat', '4_UMin_1_LFPraw.mat', '5_UMin_1_LFPraw.mat',...
%    '6_UMin_1_LFPraw.mat', '7_UMin_1_LFPraw.mat','8_UMin_1_LFPraw.mat',...
%    '9_UMin_1_LFPraw.mat','10_UMin_1_LFPraw.mat'};


patient_files = {'2_UMin_1_LFPraw.mat',...
   '3_UMin_1_LFPraw.mat', '4_UMin_1_LFPraw.mat', '5_UMin_1_LFPraw.mat',...
   '6_UMin_1_LFPraw.mat', '7_UMin_1_LFPraw.mat'};


% create main directory and folder/directory for LFP summary outputs
maindir = 'C:\Users\Admin\Downloads\MINNLFP'; % DAS
savedir = 'C:\Users\Admin\Downloads\tabForm';

cd(maindir)  % cd = change directory

for i = 1:length(folder3)
    % create patient dir


    % run function on all patient files
    [m,s,sl] = quantify_sleepLFPfun_jat(patient_files{i});

    % save outputs in new folder
    savename = ['summaryLFP_',folder3{i},'.mat'];
    cd(savedir);
    save(savename,'m','s','sl');
end

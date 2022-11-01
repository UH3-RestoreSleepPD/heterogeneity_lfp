% Figure Plotting Script 

% https://onlinelibrary.wiley.com/doi/epdf/10.1111/ejn.13610

% Determine the therapeutic contact (bipol offset, biPair) per patient (xCase)
bp_ther = readtable("SleepLFP_OriginalStudy_ContactPairs.xlsx"); 

% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2';
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data

% extract subject ID
subjectID = []; % 8609 x 1

%%
% turn into 1x5 cell arrays or 10x6x5 array

% 'W' % Wake
% 'N1' % N1
% 'N2' % N2
% 'N3' % N3
% 'R' % REM

sl_state = [];
bipol_ther = []; % 8609 (epoch) x 6 (band)
bipol_ther_mean = []; % 10 (pt) x 6 (band)
bipol_ther_std = []; % 10 (pt) x 6


for i = 1:length(summaryLFP_files) % 10 patients
    load(summaryLFP_files{i},"m", "s","sl");  % m = 1075 x 6 x 3; s = 1075 x 6 x 3; sl = 1075 x 1

    for j = 1:length(sl) % 1075 epochs
        if matches(sl{j},{'W'})
            sl_state(j) = 1;
        elseif matches(sl{j},{'N1'})
            sl_state(j) = 2;
        elseif matches(sl{j},{'N2'})
            sl_state(j) = 3;
        elseif matches(sl{j},{'N3'})
            sl_state(j) = 4;
        else matches(sl{j},{'R'})
            sl_state(j) = 5;
        end
    end
    sl_state = sl_state'; % 1149 x 1 double ... why?

%     switch sl{i}
%         case 'W'
%             % sl_state =
%         case 'N1'
%             % sl_state =
%         case 'N2'
%             % sl_state = 
%         case 'N3'
%             % sl _state =
%         case 'R'
%             % sl_state =
%     end
% 


    switch bp_ther.biPair{i}
        case '01'
            bipol_ther = [bipol_ther; m(:,:,1)];
            bipol_mean_temp = mean(m(:,:,1));
            bipol_std_temp = std(m(:,:,1));
        case '12'
            bipol_ther = [bipol_ther; m(:,:,2)];
            bipol_mean_temp = mean(m(:,:,2));
            bipol_std_temp = std(m(:,:,2));
        case '23'
            bipol_ther = [bipol_ther; m(:,:,3)];
            bipol_mean_temp = mean(m(:,:,3));
            bipol_std_temp = std(m(:,:,3));
    end
    bipol_ther_mean = [bipol_ther_mean; bipol_mean_temp];
    bipol_ther_std = [bipol_ther_std; bipol_std_temp];
    subjectID = [subjectID; repmat(i,length(m(:,:,1)),1)];
end

% rows (observations) = # patients (10) * # epochs per patient; cols_h (features) =  # bands (6); cols_d (contact combinations) = bipolar offsets (3)

% 6 bands:
% delta: 0-3 Hz
% theta: 4-7 Hz
% alpha: 8-12 Hz
% beta: 13-30 Hz
%   low beta: 13-20 Hz
%   high beta: 21-30 Hz
% gamma: 31-50 Hz (cut gamma off at 50)

%% one plot per band 
% X: ss
% Y: mean (power)
% 10 points per X location

% figure
% plot()

%%
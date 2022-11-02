% Figure Plotting Script

% https://onlinelibrary.wiley.com/doi/epdf/10.1111/ejn.13610

% Determine the therapeutic contact (bipol offset, biPair) per patient (xCase)
bp_ther = readtable("SleepLFP_OriginalStudy_ContactPairs.xlsx");

% read in quantify_sleepLFPfun / summaryLFPfun outputs
maindir = 'C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp\summaryLFP_v2';    %_v3
cd(maindir)

LFP_struct = dir('*.mat'); % creates struct of summaryLFP metadata
summaryLFP_files = {LFP_struct.name}; % pulls out only the file names of the summaryLFP data

% extract subject ID
subjectID = []; % 8609 x 1

%% Loop through sleep stages (5), patients (10), and bands (6)

bipol_ther = []; % 8609 (epochs) x 6 (bands)
sl_stages = {'W','N1','N2','N3','R'}; % 5 (sleep stages)
bipol_ther_mean = nan(10,6,5); % 10 (pt) x 6 (bands) x 5 (sleep stages)
bipol_ther_std = nan(10,6,5); % 10 (pt) x 6 (bands) x 5 (sleep stages)

for i = 1:length(summaryLFP_files) % 10 patients
    load(summaryLFP_files{i},"m", "s","sl");  % m = 1075 x 6 x 3; s = 1075 x 6 x 3; sl = 1075 x 1
    for j = 1:length(sl_stages) % 5 stages
        sl_temp = matches(sl,sl_stages{j});
        if sum(sl_temp) == 0
            continue
        end
        m2 = m(sl_temp,:,:);
        switch bp_ther.biPair{i}
            case '01'
                bipol_ther = [bipol_ther; m2(:,:,1)];
                bipol_mean_temp = mean(m2(:,:,1));
                bipol_std_temp = std(m2(:,:,1));
            case '12'
                bipol_ther = [bipol_ther; m2(:,:,2)];
                bipol_mean_temp = mean(m2(:,:,2));
                bipol_std_temp = std(m2(:,:,2));
            case '23'
                bipol_ther = [bipol_ther; m2(:,:,3)];
                bipol_mean_temp = mean(m2(:,:,3));
                bipol_std_temp = std(m2(:,:,3));
        end
        bipol_ther_mean(i,:,j) = [bipol_mean_temp];
        bipol_ther_std(i,:,j) = [bipol_std_temp];
        subjectID = [subjectID; repmat(i,length(m(:,:,1)),1)];
    end
end

% 6 bands:
% delta: 0-3 Hz
% theta: 4-7 Hz
% alpha: 8-12 Hz
% beta: 13-30 Hz
%   low beta: 13-20 Hz
%   high beta: 21-30 Hz
% gamma: 31-50 Hz (cut gamma off at 50)

%% one plot per band
% X: sleep stage
% Y: mean (power)
% 10 points per X location

for Bi = 1:size(bipol_ther_mean,2) % mean band power
    figure
    for Si = 1:size(bipol_ther_mean,3) % sleep stage
    % plot sleep stage vs. mean LFP power per patient (10)
    temp_ss = bipol_ther_mean(:,Bi,Si);
    X_id = zeros(length(temp_ss),1) + Si;
    plot(X_id,temp_ss,'o')
    hold on
    end
    hold off
    xlim([0 6])
    xlabel('Sleep Stage')
    ylabel('Mean Power')
    %title()
end

%% ANOVA by Band (6) 

% Dependent Variable = LFP Power
% Factors (2) = Patient and Sleep Stage

W = bipol_ther_mean(:,:,1);
N1 = bipol_ther_mean(:,:,2);
N2 = bipol_ther_mean(:,:,3);
N3 = bipol_ther_mean(:,:,4);
R = bipol_ther_mean(:,:,5);

% M = mean(A,'omitnan')
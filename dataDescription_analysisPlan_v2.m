%% PD Sleep LFP | Patient Heterogeneity Analysis

clc
close all
clear all

addpath(genpath('C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp'))  %ctrl A ctrl i (smart indenting)

%% Data sets:
% ======= File format explanation:

% ****************TWO NEW Data formats for current Multicenter study
% '2_UMin_1_LFP.mat'
% '2_UMin_1_LFPraw.mat'
% Subject '_' Institution '_' Night of recording '_' data

%%%%%% Ex: 2_UMin_1_LFP.mat
% Data in the file:
% ---- A timetable with LFP for each DBS channel downsampled to 250Hz
% separated into 30 second bins with a column for the sleep score

%%%%%% Ex: 2_UMin_1_LFPraw.mat
% Data in the file:
% ---- A timetable with LFP for each DBS channel at the full sample rate of
% 1024Hz separated into 30 second bins with a column for the sleep score
%
% ****************TWO OLD Data formats from original study
%%%%%% Ex: IndexPT2.mat
% Data in the file
% n by 3 matrix [n = number of 30 second epochs]
% column 1 = start sample for epoch
% column 2 = stop sample for epoch
% column 3 = sleep label [0 = 'wake', 1 = 'N1', 2 = 'N2', 3 = 'N3', 5 =
% 'REM']
%%%%%% Ex: Patient_2_Sleep_LFP.mat

% Data in the file
% Struct with 5 fields:
% --- 'data' field
%           |  n by 40 matrix [n = number of samples - 1024 sampling rate]
%           |  Columns = different sensor data
% --- 'montage' field
%           |  Labels for 40 columns in 'data'
% ---- 'Fs' field
%           |  Sampling frequency
% ---- 'pix'
%           |  Patient number
% ---- 'pt'
%           |  Patient initials

%% Work with the LFPraw.mat file

% load('2_UMin_1_LFP.mat', 'LFPTTRaw') % LFPTTRaw is an element in 2_UMin_1_LFP.mat'
%'-v7.3'

load('2_UMin_1_LFPraw.mat', 'LFPTTRaw') % LFPTTRaw is an element in 2_UMin_1_LFPraw.mat'

%% Replicate sleep state duration quantification
% I.e., calculate the average epoch number and duration (in seconds) that contiguous epoch states occur.

% W, N1, N2, N3, R
sleep_states = LFPTTRaw.FSScore; %1149x1 cell

%% call the local "sleep_score_count" function for each sleep state

[W_outputs]  = state_score_count(sleep_states, 'W', 1);  % Wake
[N1_outputs] = state_score_count(sleep_states, 'N1', 1); % N1
[N2_outputs] = state_score_count(sleep_states, 'N2', 1); % N2
[N3_outputs] = state_score_count(sleep_states, 'N3', 1); % N3
[R_outputs]  = state_score_count(sleep_states, 'R', 1);  % REM
[sleep_outputs] = state_score_count(sleep_states, 'sleep', 1); % N1, N2, N3

% test to confirm total epoch count = 1149 (number of epochs in LFPTTRaw)
test_count = W_outputs.state_count + N1_outputs.state_count + N2_outputs.state_count + N3_outputs.state_count + R_outputs.state_count; % 1149

% isolate the time column of the LFPTTRaw timetable (a 1149x1 duration)
time = LFPTTRaw.Time;

%% quant. when sleep-onset occurs --> 2-3 min of contig. sleep state

sleep_onset = sleep_outputs.start_index_blocks(find(sleep_outputs.block_dur > 150, 1, 'first'));

%% Compute relative power scaled by total power for each subject and average across stage
% Replicate heterogenous groups by Karin

% sampling rate: 250 Hz

% 5 bands:
% delta: 0-3 Hz
% theta: 4-7 Hz
% alpha: 8-12 Hz
% beta: 13-30 Hz (low beta: 13-20 Hz; high beta: 21-30 Hz)
% gamma: 31-50 Hz (cut gamma off at 50)

%% test

% length(temp_epoch)/30
Fs = 1024; % sampling Frequency (in Hz) of the data
Fl = 60; % line frequency, typically 50 or 60 Hz, the center of interpolation
neighborsToSample = 4; % Hz, tells function how large of a window (in Hz) to use when picking the constant
neighborsToReplace = 2; % Hz, tells function which neighbors need to be replaced with the constant

all_power = cell(height(LFPTTRaw),1);
x = []; % base data element = epoch
for i = 1:height(LFPTTRaw)
    temp_epoch = LFPTTRaw.("0"){i};
    % spectral interpolation function, notch filter - 60Hz noise (US), 50 (EU)
    temp_notch = spectrumInterpolation(temp_epoch, Fs, Fl, neighborsToSample, neighborsToReplace); % interpolates around the frequency of interest (Fl) and replaces its and some neighbors using a constant value
    temp_hp = highpass(temp_notch,0.5,Fs); % filter out everything below 0.5 Hz (0.1 or 0.5 Hz - gets rid of large mag)

    % pspectrum --> power, freq
    [power, freq] = pspectrum(temp_hp,Fs,"FrequencyLimits",[0 80]);        % 0-80 or 0-100? Either's fine (anything beyond 50 is ok)
    % convert pwr to decibels -->  10*log(10)
    power_decibel = 10*log10(power);                                       % power_decibel outputs all negative values ... expected? Fine

    % fill cell array with power value per epoch
    all_power{i} = power_decibel;

    disp(['Epoch #', num2str(i)])
end
test=1;

% unpack all power values for full electrode
power_matrix = [all_power{:}]; % matix: 4096 power values x 1149 epochs

% reformat matrix --> column vector of all power values
power_vec = reshape(power_matrix, numel(power_matrix),1); % numel --> outputs # of elements

% normalize across entire night of recording (all epochs)
power_norm = normalize(power_vec,"range"); % range default: 0-1

% repack full normalized night of recording data
power_norm_matrix = reshape(power_norm,size(power_matrix)); % vec --> matrix

% Visual Sanity Check
% plot comparision - one plot of all epochs before/after normalizing (use subplots)
figure
subplot(1,2,1)
plot(freq, power_matrix)
xlabel('frequency')
ylabel('power')
title('power spectrum of all epochs before normalizing')
subplot(1,2,2)
plot(freq, power_norm_matrix)
xlabel('frequency')
ylabel('normalized power')
title('power spectrum of all epochs after normalizing')
% test on contact 1 and 2 to see whether alpha/beta bump is present

% storage arrays for power mean and std. (devided by freq band)
mean_storage = zeros(width(power_norm_matrix),6);
std_storage = zeros(size(mean_storage));

for i = 1:width(power_norm_matrix) % width --> columns                      % band boundaries? use conditionals
    % create (indexed power value vector per freq band) to run std on       % conditionals create logical vectors (1s and 0s) using ~ boolean logic
    delta_i = power_norm_matrix(freq >= 0 & freq <= 3, i);                  % delta: 0-3 Hz
    theta_i = power_norm_matrix(freq > 3 & freq <= 7, i);                   % theta: 4-7 Hz
    alpha_i = power_norm_matrix(freq > 7 & freq <= 12, i);                  % alpha: 8-12 Hz
    l_beta_i = power_norm_matrix(freq > 12 & freq <= 20, i);                % low beta: 13-20 Hz
    h_beta_i = power_norm_matrix(freq > 20 & freq <= 30, i);                % high beta: 21-30 Hz
    gamma_i = power_norm_matrix(freq > 30 & freq <= 50, i);                 % gamma: 31-50 Hz

    [S_delta, M_delta] = std(delta_i);                                      % how do I make this a loop / reduce lines of code?
    [S_theta, M_theta] = std(theta_i);
    [S_alpha, M_alpha] = std(alpha_i);
    [S_l_beta, M_l_beta] = std(l_beta_i);
    [S_h_beta, M_h_beta] = std(h_beta_i);
    [S_gamma, M_gamma] = std(gamma_i);
                                                                            % how do I make this a loop / reduce lines of code?
    mean_storage(i,1) = M_delta;
    std_storage(i,1) = S_delta;

    mean_storage(i,2) = M_theta;
    std_storage(i,2) = S_theta;

    mean_storage(i,3) = M_alpha;
    std_storage(i,3) = S_alpha;

    mean_storage(i,4) = M_l_beta;
    std_storage(i,4) = S_l_beta;

    mean_storage(i,5) = M_h_beta;
    std_storage(i,5) = S_h_beta;

    mean_storage(i,6) = M_gamma;
    std_storage(i,6) = S_gamma;

    %     for j = 1:6
    %         mean_storage(i,j) =
    %
    %     end

    %     for k = 1:6
    %         std_storage(i,k) =
    %
    %     end

end

% i loops through epochs (columns) -- > create row vec.


%% notes with JAT

% normalize the power
% norm = normalize(decibel,'range'); % range scale from 0 - 1 --> look at normalize documentation

% use norm when indexing
% find freq. indcices for each band (5 bands)
% gamma cut off for at 50

% loop through freq bin designations
% find where freq > 0 but < 4
% mean pwr per band
% meach stdev


%% Compute cosine similarity by patient and sleep stage

% % Compare
% Cs1 = getCosineSimilarity(x,y);
% Cs2 = (pdist(x,y,'cosine')) + 1;


%% Local Function
% Inputs (2):
% input 1 (scores): LFP sleep score data (LFPTTRaw.FSScore --> sleep_states)
% input 2 (state): State to be counted (the FSScore: W, N1, N2, N3, R)
% Outputs (5):
% output 1 (score_state_matches): logical vector assessing if each epoch score matches the state being counted,
% output 2 (state_epoch_vector): vector counting contiguous epoch states as block counts within full epoch set,
% output 3 (state_count): count (or sum) of epoch scores that match the state being counted,
% output 4 (state_last_count): trimmed version of output 2 storing only the counted epoch state matches / contiguous blocks
% output 5 (start_index_blocks): vector of the start indices per contiguous state-matched epoch block

function [outputs] = state_score_count(scores, state, plot_flag)

% switch b/t state vs. contig. sleep state
switch state
    case 'sleep' % N1, N2, N3
        score_state_matches = matches(scores, {'N1', 'N2', 'N3'});

    otherwise
        score_state_matches = matches(scores, state); % set 1 for all scores labeled state (every row where scores = state), 0 otherwise
end

state_count = sum(score_state_matches);   % total up all the 1's in score_state_matches (all the rows where where scores = state)

scores_length = length(scores);           % 1149 scored epochs
epoch_count = 1;                          % initialize epoch counter
state_epoch_vector = nan(scores_length, 2); % initialize the epoch vector (preallocate empty vec)
start_index_blocks = nan(scores_length, 2); % preallocate empty vector with same dimensions as state_epoch_vector
block_count = 1;                          % initialize block counter

for i = 1:scores_length     % iterate over all rows in scores (logical)
    tempe = score_state_matches(i);       % simplify variable name (i = row index of score_state_matches)

    if tempe == 1 % if score = state, increment the epoch count
        if epoch_count == 1
            start_index_blocks(block_count) = i;
        end
        epoch_count = epoch_count + 1;
        % state_epoch_vector(block_count, 1) = epoch_count;       % store the current epoch count

    else          % otherwise, store the epoch count and start fresh
        if epoch_count == 1  % fix issue with block count incrementing with continuous non-state matches
            continue
        else
            state_epoch_vector(block_count, 1) = epoch_count;     % store the current epoch count
            block_count = block_count + 1;                        % increment to the next block
        end
        epoch_count = 1;                                          % start a new epoch count
    end
end

state_last_count = state_epoch_vector(~isnan(state_epoch_vector(:,1)),1); % trimming NaNs - want to know where NaNs are Not; just store a vector of the counted epoch state matches / block-counts
start_index_blocks = start_index_blocks(~isnan(start_index_blocks(:,1)),1); % trimming NaNs - just store a vector of the start indices per state-match block

% need to calculate the average epoch number and duration (in seconds) that contiguous epoch states occur
block_dur = state_last_count.*30; % put '.' element-wise computation (rather than matirx mult.)

% output structure for each state
outputs.score_state_matches = score_state_matches;
outputs.state_epoch_vector = state_epoch_vector;
outputs.state_count = state_count;
outputs.state_last_count = state_last_count;
outputs.start_index_blocks = start_index_blocks;
outputs.block_dur = block_dur;

% Visual Sanity Check
if plot_flag
    % plot output structure
    figure
    plot(score_state_matches)
    ylim([0 1.5])
    hold on
    % plot start indexes of of block locations (x,y) with colored astrices
    y_astices = ones(size(start_index_blocks));
    plot(start_index_blocks,y_astices,'r*')
    xlabel('Sleep LFP Epochs')
    ylabel('Sleep State Matches')
    title(state)
end

end


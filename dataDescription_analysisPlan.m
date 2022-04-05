%% PD Sleep LFP | Patient Heterogeneity Analysis

clc
close all
clear all

addpath(genpath('C:\MATLAB\GitHub\UH3-RestoreSleepPD\heterogeneity_lfp')) %cntr A cntrl i (smart indenting)

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
% I.e., calculate the average epoch number and duration (in seconds) that
% contiguous epoch states occur.

sleep_states = LFPTTRaw.FSScore; %1149x1 cell
% W, N1, N2, N3, R

% visualize sleep state distribution --> histogram

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

% quantify each state duration; epoch = 30s
% calculate the average epoch number and duration (in seconds) that contiguous epoch states occur

%% Compute relative power scaled by total power for each subject and average across stage
% Replicate heterogenous groups by Karin

% sampling rate: 250 Hz

% 5 bands:
    % delta: 0-3 Hz
    % theta: 4-7 Hz
    % alpha: 8-12 Hz
    % beta: 13-30 Hz (low beta: 13-20 Hz; high beta: 21-30 Hz) 
    % gamma: 31-50 Hz (cut gamma off at 50)

% f_LFP = fft(LFPTTRaw,5,)
% x = LFPTTRaw(:, 1:4);

% https://www.mathworks.com/help/ident/ug/transforming-between-time-and-frequency-domain.html
% https://www.gaussianwaves.com/2013/12/computation-of-power-of-a-signal-in-matlab-simulation-and-verification/#:~:text=The%20p-norm%20in%20Matlab%20is%20computed%20as%20By,and%20divide%20by%20the%20length%20of%20the%20signal.

%% test

% length(temp_epoch)/30
Fs = 1024; % sampling Frequency (in Hz) of the data
Fl = 60; % line frequency, typically 50 or 60 Hz, the center of interpolation
neighborsToSample = 4; % Hz, tells function how large of a window (in Hz) to use when picking the constant 
neighborsToReplace = 2; % Hz, tells function which neighbors need to be replaced with the constant

x = []; % base data element = epoch
for i = 1:height(LFPTTRaw)
    temp_epoch = LFPTTRaw.("0"){i};
    % spectral interpolation function, notch filter - 60Hz noise (US), 50 (EU)
    temp_notch = spectrumInterpolation(temp_epoch, Fs, Fl, neighborsToSample, neighborsToReplace); % interpolates around the frequency of interest (Fl) and replaces its and some neighbors using a constant value
    temp_hp = highpass(temp_notch,0.5,Fs); % filter out everything below 0.5 Hz (0.1 or 0.5 Hz - gets rid of large mag)

    % pspectrum --> power, freq
    [power, freq] = pspectrum(temp_hp,Fs,"FrequencyLimits",[0 80]);
    % convert pwr to decibels -->  10*log(10)
    power_decibel = 10*log10(power);
    smooth_power = smoothdata(power_decibel,'movmean',30);

    % compute the average power per frequency band (5)
    p_delta = bandpower(temp_hp,Fs,[0 3]); % delta: 0-3 Hz
    p_theta = bandpower(temp_hp,Fs,[4 7]); % theta: 4-7 Hz
    p_alpha = bandpower(temp_hp,Fs,[8 12]); % alpha: 8-12 Hz
    p_beta = bandpower(temp_hp,Fs,[13 30]); % low beta: 13-20 Hz; high beta: 21-30 Hz
    p_gamma = bandpower(temp_hp,Fs,[31 50]); % gamma: 31-50 Hz (cut gamma off at 50)

    % Alt method: 
    % compute the average power and standard deviation per frequency band (5)

    % storage array for the 5 bands' stdevs and mean powers
    %[S,M] = zeros(5,2);

    %for j = 1:5
    % transform below into 1 loop

    [power_delta, freq_delta] = pspectrum(temp_hp, Fs, "FrequencyLimits", [0 3]); % delta band power spectrum
    power_delta_decibel = 10*log10(power_delta);
    smooth_power_delta = smoothdata(power_delta_decibel,'movmean',30);
    [S_delta, M_delta] = std(smooth_power_delta);

    [power_theta, freq_theta] = pspectrum(temp_hp, Fs, "FrequencyLimits", [4 7]); % theta band power spectrum
    power_theta_decibel = 10*log10(power_theta);
    smooth_power_theta = smoothdata(power_theta_decibel,'movmean',30);
    [S_theta, M_theta] = std(smooth_power_theta);

    [power_alpha, freq_alpha] = pspectrum(temp_hp, Fs, "FrequencyLimits", [8 12]); % alpha band power spectrum
    power_alpha_decibel = 10*log10(power_alpha);
    smooth_power_alpha = smoothdata(power_alpha_decibel,'movmean',30);
    [S_alpha, M_alpha] = std(smooth_power_alpha);

    [power_beta, freq_beta] = pspectrum(temp_hp, Fs, "FrequencyLimits", [13 30]); % beta band power spectrum
    power_beta_decibel = 10*log10(power_beta);
    smooth_power_beta = smoothdata(power_beta_decibel,'movmean',30);
    [S_beta, M_beta] = std(smooth_power_beta);

    [power_gamma, freq_gamma] = pspectrum(temp_hp, Fs, "FrequencyLimits", [31 50]); % gamma band power spectrum
    power_gamma_decibel = 10*log10(power_gamma);
    smooth_power_gamma = smoothdata(power_gamma_decibel,'movmean',30);
    [S_gamma, M_gamma] = std(smooth_power_gamma);


%     % compute the standard deviation per frequency band (5)
%     %[S,M] = std(___)
%     std_delta = std(); % delta: 0-3 Hz
%     std_theta = std(); % theta: 4-7 Hz
%     std_alpha = std(); % alpha: 8-12 Hz
%     std_beta = std(); % low beta: 13-20 Hz; high beta: 21-30 Hz
%     std_gamma = std(); % gamma: 31-50 Hz (cut gamma off at 50)
    
    % loop through freq bin designations
    % find where freq > 0 but < 4 
    % mean pwr per band
    % meach stdev
        
end

figure
plot(freq,smooth_power)
title('smoothed power')
figure
plot(freq_delta,smooth_power_delta)
title('\delta power')
figure
plot(freq_theta,smooth_power_theta)
title('\theta power')
figure
plot(freq_alpha,smooth_power_alpha)
title('\alpha power')
figure
plot(freq_beta,smooth_power_beta)
title('\beta power')
figure
plot(freq_gamma,smooth_power_gamma)
title('\gamma power')


% %pspec = pspectrum(x);
% %norm = normalize(pspec,'range',[0,1]);
% 
% figure
% plot(norm)
% ylim([-0.001, 0.5])
% xlim([0,500])
% xlabel('frequency')
% ylabel('power spectrum')
% 
% LFP_mat_1 = LFPTTRaw.("1"){:};
% LFP_1 = LFP_mat_1(:);


%% notes with JAT

% normalize the power
% norm = normalize(decibel,'range'); % range scale from 0 - 1 --> look at normalize documentation 

% use norm when indexing 
% find freq. indcices for each band (5 bands)
% gamma cut off for at 50

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

state_count = sum(score_state_matches);       % total up all the 1's in score_state_matches (all the rows where where scores = state)

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
        % state_epoch_vector(block_count, 1) = epoch_count;     % store the current epoch count

    else          % otherwise, store the epoch count and start fresh
        if epoch_count == 1  % fix issue with block count incrementing with continuous non-state matches 
            continue
        else
            state_epoch_vector(block_count, 1) = epoch_count;     % store the current epoch count
            block_count = block_count + 1;                        % increment to the next block
        end
        epoch_count = 1;                                      % start a new epoch count
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


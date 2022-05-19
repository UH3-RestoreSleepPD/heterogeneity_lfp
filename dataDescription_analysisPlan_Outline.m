%% PD Sleep LFP | Patient Heterogeneity Analysis Outline


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

%% Load LFPraw.mat file

% LFPTTRaw is an element in 2_UMin_1_LFPraw.mat'

%% Replicate sleep state duration quantification
% I.e., calculate the average epoch number and duration (in seconds) that contiguous epoch states occur.

% W, N1, N2, N3, R

% call the local "sleep_score_count" function for each sleep state

% isolate the time column of the LFPTTRaw timetable (a 1149x1 duration)

% quantify when sleep-onset occurs (after 2-3 min of contig. sleep state)

%% Compute relative power scaled by total power for each subject and average across stage
% Replicate heterogenous groups by Karin

% sampling rate: 250 Hz

% 5 bands:
% delta: 0-3 Hz
% theta: 4-7 Hz
% alpha: 8-12 Hz
% beta: 13-30 Hz (low beta: 13-20 Hz; high beta: 21-30 Hz)
% gamma: 31-50 Hz (cut gamma off at 50)

% run each channel / contact (0,1,2,3) through spectrumInterpolation,
% (notch filter - 60Hz noise (US), 50 (EU)), highpass filter, and 
% pspectrum functions, and then convert power to decibels

% unpack all power values for full electrode
% reformat matrix --> column vector of all power values
% normalize across entire night of recording (all epochs)
% repack full normalized night of recording data

% compute power mean and std. per frequency band (devided by freq band)
    % use conditionals
    % conditionals create logical vectors (1s and 0s) using ~ boolean logic
    

%% Compute cosine similarity by patient and sleep stage
% Compare
% Cs1 = getCosineSimilarity(x,y);
% Cs2 = (pdist(x,y,'cosine')) + 1;



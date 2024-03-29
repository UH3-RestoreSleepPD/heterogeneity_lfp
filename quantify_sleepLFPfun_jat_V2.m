function [mean_storage, std_storage,...
          sleep_statesOUT , bipolar_storageO,...
          power_norm_matrix] = quantify_sleepLFPfun_jat_V2(patient)

% Inputs (1):
% input 1 (patient): filename of patient's raw LFP data

% Outputs (#):
% output 1 (mean_storage): mean power per frequency band (6 columns) per LFP 
% epoch (# rows) per bipolar offset (3)
% output 2 (std_storage): mean standard dev. per freqency band (6) per LFP 
% epoch (# rows) per bipolar offset (3)
% output 3 (sleep_states): average epoch number and duration (in seconds) 
% that contiguous epoch states occur.

%% PD Sleep LFP | Patient Heterogeneity Analysis

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

%patient = '2_UMin_1_LFPraw.mat';
load(patient, 'LFPTTRaw') % LFPTTRaw is an element in '2_UMin_1_LFPraw.mat'

%% Replicate sleep state duration quantification
% I.e., calculate the average epoch number and duration (in seconds) that 
% contiguous epoch states occur.

% W, N1, N2, N3, R
sleep_states = LFPTTRaw.FSScore; % epoch_count x 1 cell

%% call the local "sleep_score_count" function for each sleep state

% [W_outputs]  = state_score_count(sleep_states, 'W', 0);  % Wake
% [N1_outputs] = state_score_count(sleep_states, 'N1', 0); % N1
% [N2_outputs] = state_score_count(sleep_states, 'N2', 0); % N2
% [N3_outputs] = state_score_count(sleep_states, 'N3', 0); % N3
% [R_outputs]  = state_score_count(sleep_states, 'R', 0);  % REM
% [sleep_outputs] = state_score_count(sleep_states, 'sleep', 0); % N1, N2, N3

%% quantify when sleep-onset occurs (after 2-3 min of contig. sleep state)

% sleep_onset = sleep_outputs.start_index_blocks(find(sleep_outputs.block_dur 
% > 150, 1, 'first'));

%% Compute relative power scaled by total power for each subject and average across stage
% Replicate heterogenous groups by Karin

% sampling rate: 250 Hz

% 6 bands:
% delta: 0-3 Hz
% theta: 4-7 Hz
% alpha: 8-12 Hz
% beta: 13-30 Hz
%   low beta: 13-20 Hz
%   high beta: 21-30 Hz
% gamma: 31-50 Hz (cut gamma off at 50)

% remove time and FFScore columns from LFPTTRaw
rawLFP = table2cell(LFPTTRaw(:,1:4));

% 2 constants
epoch_number = height(rawLFP);
epoch_length = length(rawLFP{1,1}); % number of samples in epoch

bipolar_storage = cell(epoch_number,3);

% loop through LFP contacts and compute bipolar offsets
for i = 1:3
    % bpt = LFPTTRaw(:,i:i+1);
    % unpack cell arrays 
    col1 = rawLFP(:,i);
    col1_unpack = cell2mat(col1);
    col2 = rawLFP(:,i+1);
    col2_upack = cell2mat(col2);

    % compute bipolar offset (0-1, 1-2, 2-3) 
    bp_offset = col1_unpack - mean([col1_unpack, col2_upack],2);             
    % subtract mean off of most dorsal contact

    % re-bundle back into cell array --> bipolar_storage
    bp_matrix = reshape(bp_offset,epoch_length,epoch_number); 
    bp_cell = cell(epoch_number,1);
    for bpi = 1:epoch_number
        bp_cell{bpi} = bp_matrix(:,bpi);
    end

    bipolar_storage(:,i) = bp_cell;

end

% Compute bipolar references (4 col --> 3 col)
% 0-1 --> 0 - mean(0 - 1)
% 1-2 --> 1 - mean(1 - 2)
% 2-3 --> 2 - mean(2 - 3)

%% create outer loop for all contacts (0,1,2,3)

% length(temp_epoch)/30
Fs = 1024; % sampling Frequency (in Hz) of the data
Fl = 60; % line frequency, typically 50 or 60 Hz, the center of interpolation
neighborsToSample = 4; % Hz, tells function how large of a window (in Hz) 
% to use when picking the constant
neighborsToReplace = 2; % Hz, tells function which neighbors need to be 
% replaced with the constant

all_power_bp = cell(epoch_number,3);

% loop through the 3 bipolar references (bipolar_storage)
for bpi = 1:3                                                                 
    % 1:width(bipolar_storage)
    for i = 1:epoch_number
        temp_epoch = cell2mat(bipolar_storage(i,bpi));
        % spectral interpolation function, notch filter - 60Hz noise (US), 50 (EU)
        temp_notch = spectrumInterpolation(temp_epoch, Fs, Fl, neighborsToSample,...
            neighborsToReplace); % interpolates around the frequency of interest (Fl) 
        % and replaces its and some neighbors using a constant value
        temp_hp = highpass(temp_notch,0.5,Fs); % filter out everything below 0.5 Hz 
        % (0.1 or 0.5 Hz - gets rid of large mag)

        % pspectrum --> power, freq
        [power, freq] = pspectrum(temp_hp,Fs,"FrequencyLimits",[0 80]);
        % convert pwr to decibels -->  10*log(10)
        power_decibel = 10*log10(power);

        % fill cell array with power value per epoch
        all_power_bp{i,bpi} = power_decibel;

        disp(['Epoch #', num2str(i), ', Bipolar Reference #' num2str(bpi)])
    end
end

% bp_01 = bipolar_storage(:,1);
% bp_12 = bipolar_storage(:,2);
% bp_23 = bipolar_storage(:,3);

%% make outputs 3 (mean) and 4 (std) matrices: epoch (# rows) by band (6 col) by bipolar ref (3)

% initialize storage container
keepEpsAll = cell(1,3);
for bpi = 1:3 
    %for i = 1:epoch_number
    % unpack all power values for full electrode
    power_matrix1 = all_power_bp(:,bpi);
    power_matrix = [power_matrix1{:}]; % matix: 4096 power values x 1149 epochs

    % reformat matrix --> column vector of all power values
    power_vec = reshape(power_matrix, numel(power_matrix),1); % numel --> outputs # of elements

    powerEpId = zeros(size(power_vec));
    start = 1;
    stop = 4096;
    for pi = 1:size(power_matrix,2)
        powerEpId(start:stop) = pi;
        start = stop + 1;
        stop = start + 4096;
    end

    thresh = mean(power_vec) + (std(power_vec)*5);

    epIDsArt = unique(powerEpId(power_vec > thresh));
    keepEps = ones(size(power_matrix,2),1,'logical');
    if ~isempty(epIDsArt)
        keepEps(epIDsArt) = false;

        keepEpsAll{bpi} = keepEps;
    else
        keepEpsAll{bpi} = keepEps;
    end

end

% Fix KeepEpsAll so it is true for all rows
allLogKeep = cell2mat(keepEpsAll);
allLogKeepF = zeros(height(allLogKeep),1);
for ki = 1:height(allLogKeep)
    tmpROW = allLogKeep(ki,:);
    if sum(tmpROW) == 3
        allLogKeepF(ki) = 1;
    end
end

power_norm_matrix = cell(1,3);
slpn = cell(1,3);
for bpi = 1:3 
    %for i = 1:epoch_number
    % unpack all power values for full electrode
    power_matrix1 = all_power_bp(:,bpi);
    power_matrix = [power_matrix1{:}]; % matix: 4096 power values x 1149 epochs

    power_matrixAR = power_matrix(:,logical(allLogKeepF));
    power_vecAR = reshape(power_matrixAR, numel(power_matrixAR),1);
    power_vec = power_vecAR;
    power_matrix = power_matrixAR;
    slpn{1,bpi} = sleep_states(logical(allLogKeepF));
    

    % normalize across entire night of recording (all epochs)
    power_norm = normalize(power_vec,"range"); % range default: 0-1
    
    % reshape full normalized night of recording data
    reshape_power_norm = reshape(power_norm,size(power_matrix)); % vec --> matrix
    for epi = 1:width(reshape_power_norm)     % loop through epoch number
        %repack
        power_norm_matrix{1,bpi}{epi,1} = reshape_power_norm(:,epi);
    end
end
sleep_statesOUT = slpn;
bipolar_storageO = bipolar_storage(logical(allLogKeepF),:);



% storage arrays for power mean and std. (devided by freq band)
mean_storage = zeros(width(reshape_power_norm),6,3);
std_storage = zeros(size(mean_storage));

for bpi = 1:3
    for i = 1:height(power_norm_matrix{bpi}) % width --> columns                  
        % band boundaries --> use conditionals
        % create (indexed power value vector per freq band) to run std on   
        % conditionals create logical vectors (1s and 0s) using ~ boolean logic
        % create temp var that extracts epoch of interest in form of double
        temp_epochoi = power_norm_matrix{bpi}{i};

        delta_i = temp_epochoi(freq >= 0 & freq <= 3);              % delta: 0-3 Hz
        theta_i = temp_epochoi(freq > 3 & freq <= 7);               % theta: 4-7 Hz
        alpha_i = temp_epochoi(freq > 7 & freq <= 12);              % alpha: 8-12 Hz
        l_beta_i = temp_epochoi(freq > 12 & freq <= 20);            % low beta: 13-20 Hz
        h_beta_i = temp_epochoi(freq > 20 & freq <= 30);            % high beta: 21-30 Hz
        gamma_i = temp_epochoi(freq > 30 & freq <= 50);             % gamma: 31-50 Hz

        [std_storage(i,1,bpi), mean_storage(i,1,bpi)] = std(delta_i);
        [std_storage(i,2,bpi), mean_storage(i,2,bpi)] = std(theta_i);
        [std_storage(i,3,bpi), mean_storage(i,3,bpi)] = std(alpha_i);
        [std_storage(i,4,bpi), mean_storage(i,4,bpi)] = std(l_beta_i);
        [std_storage(i,5,bpi), mean_storage(i,5,bpi)] = std(h_beta_i);
        [std_storage(i,6,bpi), mean_storage(i,6,bpi)] = std(gamma_i);
    end
end

end

%% Local Function
% Inputs (2):
% input 1 (scores): LFP sleep score data (LFPTTRaw.FSScore --> sleep_states)
% input 2 (state): State to be counted (the FSScore: W, N1, N2, N3, R)
% Outputs (5):
% output 1 (score_state_matches): logical vector assessing if each 
% epoch score matches the state being counted,
% output 2 (state_epoch_vector): vector counting contiguous epoch 
% states as block counts within full epoch set,
% output 3 (state_count): count (or sum) of epoch scores that match 
% the state being counted,
% output 4 (state_last_count): trimmed version of output 2 storing only 
% the counted epoch state matches / contiguous blocks
% output 5 (start_index_blocks): vector of the start indices per contiguous 
% state-matched epoch block

function [outputs] = state_score_count(scores, state, plot_flag)

% switch b/t state vs. contig. sleep state
switch state
    case 'sleep' % N1, N2, N3
        score_state_matches = matches(scores, {'N1', 'N2', 'N3'});

    otherwise
        score_state_matches = matches(scores, state); % set 1 for all scores 
        % labeled state (every row where scores = state), 0 otherwise
end

state_count = sum(score_state_matches);   % total up all the 1's in score_state_matches 
% (all the rows where where scores = state)

scores_length = length(scores);           % 1149 scored epochs
epoch_count = 1;                          % initialize epoch counter
state_epoch_vector = nan(scores_length, 2); % initialize the epoch vector 
% (preallocate empty vec)
start_index_blocks = nan(scores_length, 2); % preallocate empty vector with 
% same dimensions as state_epoch_vector
block_count = 1;                          % initialize block counter

for i = 1:scores_length     % iterate over all rows in scores (logical)
    tempe = score_state_matches(i);       % simplify variable name (i = row 
    % index of score_state_matches)

    if tempe == 1 % if score = state, increment the epoch count
        if epoch_count == 1
            start_index_blocks(block_count) = i;
        end
        epoch_count = epoch_count + 1;
        % state_epoch_vector(block_count, 1) = epoch_count;       
        % store the current epoch count

    else          % otherwise, store the epoch count and start fresh
        if epoch_count == 1  % fix issue with block count incrementing with 
            % continuous non-state matches
            continue
        else
            state_epoch_vector(block_count, 1) = epoch_count;     
            % store the current epoch count
            block_count = block_count + 1;                        
            % increment to the next block
        end
        epoch_count = 1;                                          
        % start a new epoch count
    end
end

state_last_count = state_epoch_vector(~isnan(state_epoch_vector(:,1)),1); 
% trimming NaNs - want to know where NaNs are Not; just store a vector of the 
% counted epoch state matches / block-counts
start_index_blocks = start_index_blocks(~isnan(start_index_blocks(:,1)),1);
% trimming NaNs - just store a vector of the start indices per state-match block

% need to calculate the average epoch number and duration (in seconds) 
% that contiguous epoch states occur
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


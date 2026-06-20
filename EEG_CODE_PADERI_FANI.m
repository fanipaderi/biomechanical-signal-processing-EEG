%% 1. INITIALIZATION & DATA LOADING
clc; clear; close all;

% Load EEG DATA
filename = 'EEG_DATA.csv';
x = readmatrix(filename);
x(isnan(x)) = 0; % Handle missing values

fs = 2000; % Original Sampling Frequency (2000 Hz)

%% 2. TEMPORAL TRIMMING (Remove Setup/Teardown Artifacts)
% Remove first 6 seconds and last 6 seconds of recordings
samples_in_5_sec = 6 * fs; 
samples_in_6_sec = 6 * fs; 

x = x(samples_in_6_sec+1 : end, :);
x = x(1 : end-samples_in_6_sec, :);

% Plot initial raw trimmed data
t = (0:length(x)-1)/fs;
figure('Name', 'Raw Trimmed EEG');
plot(t, x, 'Color', [0.7 0.7 0.7]);
title('Raw Trimmed EEG Signal');
xlabel('Time (s)'); ylabel('Amplitude');

%% 3. RESAMPLING & FILTERING
tx = 0:1/fs:(length(x)-1)/fs;
targetSampleRate = 256; % Downsample to 256 Hz

[y, ty] = resample(x, tx, targetSampleRate);

% Apply Bandstop (Notch) and Bandpass filters
y = bandstop(y, [49 51], targetSampleRate, 'Steepness', 0.85, 'StopbandAttenuation', 60);
y = highpass(y, 2, targetSampleRate, 'Steepness', 0.85, 'StopbandAttenuation', 60);
y = lowpass(y, 70, targetSampleRate, 'Steepness', 0.85, 'StopbandAttenuation', 60);

%% 4. WAVELET DENOISING
clean_EEG = wdenoise(y, 10, ...
    'Wavelet', 'db2', ...
    'DenoisingMethod', 'Bayes', ...
    'ThresholdRule', 'Hard', ...
    'NoiseEstimate', 'LevelDependent');

%% 5. FEATURE EXTRACTION: SPECTRAL ANALYSIS (PSD via Welch's Method)
% Define frequency ranges for bands
f_alpha = [8 13];
f_beta  = [13 30];
f_gamma = [30 45];

% Set window length and overlap (2-sec window)
win_len = 2 * targetSampleRate; 
overlap = win_len / 2; 

% Initialize Output Vectors
num_channels = size(clean_EEG, 2);
RMS_power   = zeros(1, num_channels);
alpha_power = zeros(1, num_channels);
beta_power  = zeros(1, num_channels);
gamma_power = zeros(1, num_channels);

% Loop through each channel (column) to compute Band Power
for i = 1:num_channels
    % 1. Calculate RMS
    RMS_power(i) = rms(clean_EEG(:, i));

    % 2. Compute PSD estimate using Welch's method
    [pxx, f] = pwelch(clean_EEG(:, i), win_len, overlap, [], targetSampleRate);

    % 3. Extract Alpha Power
    idx_alpha = find(f >= f_alpha(1) & f <= f_alpha(2));
    alpha_power(i) = sum(pxx(idx_alpha));

    % 4. Extract Beta Power
    idx_beta = find(f >= f_beta(1) & f <= f_beta(2));
    beta_power(i) = sum(pxx(idx_beta));

    % 5. Extract Low Gamma Power
    idx_gamma = find(f >= f_gamma(1) & f <= f_gamma(2));
    gamma_power(i) = sum(pxx(idx_gamma));
end

%% 6. DATA EXPORT
% Create a summary table of the extracted clinical features
FeaturesTable = table((1:num_channels)', RMS_power', alpha_power', beta_power', gamma_power', ...
    'VariableNames', {'Channel', 'RMS', 'Alpha_Power', 'Beta_Power', 'Gamma_Power'});

writetable(FeaturesTable, 'EEG_Extracted_Features.xlsx');
disp('EEG Spectral Analysis & Feature Extraction Complete.');
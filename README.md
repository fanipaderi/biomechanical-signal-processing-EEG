# biomechanical-signal-processing-EEG
Automated Biomechanical Signal Processing 
## Overview
This repository contains a MATLAB-based clinical data pipeline designed to preprocess, denoise, and analyze raw Electroencephalogram (EEG) signals. The script is optimized to handle high-frequency neurological time-series data, extract critical frequency-domain features (Alpha, Beta, and Low Gamma band power), and structure the output for downstream clinical evaluation and statistical modeling.
## Workflow
**Data Optimization & Temporal Trimming:** Automatically parses raw data arrays, removing initial and terminal segments (e.g., first 6s and last 6s) to eliminate setup/teardown artifacts and ensure stable baseline recordings.
**Resampling & Down-conversion:** Efficiently downsamples high-frequency raw inputs (from 2000 Hz to an optimal 256 Hz target rate) to reduce computational load while preserving necessary physiological frequencies.
**Noise Suppression:** 
  * Implements a 50Hz bandstop (notch) filter with strict attenuation (60dB) to remove power-line interference.
  * Applies highpass (2Hz) and lowpass (70Hz) filtering to isolate the clinically relevant neurological frequency band.
**Wavelet Denoising:**  noise estimation to isolate true neural signals from complex background artifacts without distorting the underlying data structure.
**Frequency Domain Analysis (Feature Extraction):**
  * Computes the Power Spectral Density (PSD) using **Welch’s averaging estimator**.
  * Quantifies absolute band power across key neurological states: **Alpha** (8-13 Hz), **Beta** (13-30 Hz), and **Low Gamma** (30-45 Hz).
  * Calculates the Root Mean Square (RMS) of the denoised signal.
* **Automated Data Structuring:** Aggregates all extracted physiological features (RMS, Alpha, Beta, Gamma power) into structured arrays and automates the export to `.xlsx` format for statistical analysis or other
## Technologies & Methods Used
**Language:** MATLAB
**Key Techniques:** Time-Series cutting, Resampling, Wavelet Denoising, Power Spectral Density (PSD) Estimation, Clinical Feature Extraction.

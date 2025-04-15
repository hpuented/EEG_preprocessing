# 🧠 DeepEpoch

**DeepEpoch** is a MATLAB-based pipeline for preprocessing and analyzing long-term EEG recordings.  
Designed for 3+ hour `.edf` files, it provides tools to extract meaningful neural features (power, connectivity, and entropy) from clean EEG data.

---

## 📊 What It Does

This pipeline runs in **MATLAB** and includes:

1. **🧼 Preprocessing**
   - Load raw `.edf` EEG (3-hour sessions)
   - Select clean epochs using spectrograms
   - Filter EEG (e.g. 1–40 Hz, notch at 50/60 Hz)
   - Apply ICA to remove ocular/muscle artifacts

2. **📈 Feature Extraction**
   - **Power Analysis** via FFT
   - **Connectivity** using dWPLI and iCOH
   - **Entropy** using Sample Entropy (SampEn)

---

## 📂 Files Overview

| File | Description |
|------|-------------|
| `get_eeg.m` | Loads raw `.edf` EEG file and prepares it for processing |
| `get_epochs.m` | Epoch rejection |
| `filtering.m` and `ica.m` | Applies bandpass (0.25 to 70 Hz), notch (50 Hz), notch (harmonics, patient dependent) & CAR filtering, then ICA |
| `get_fft.m` | Extracts frequency band power using FFT |
| `get_dwpli.m` and `get_Imgcoherence.m` | Computes dWPLI and iCOH for functional connectivity |
| `get_SampEn.m` | Calculates Sample Entropy on cleaned EEG |

---

## 🚀 Requirements

- **MATLAB R2020b+**
- Signal Processing Toolbox
- EEGLAB (recommended): [https://sccn.ucsd.edu/eeglab/](https://sccn.ucsd.edu/eeglab/)
- [Entropy toolbox](https://www.mathworks.com/matlabcentral/fileexchange/37289-sample-entropy)

# 🧠 DeepEpoch

**DeepEpoch** is a MATLAB-based pipeline for preprocessing and analyzing long-term EEG recordings.  
Designed for 3+ hour `.edf` files, it provides tools to extract meaningful neural features—power, connectivity, and entropy—from clean EEG data.

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
| `01_load_edf.m` | Loads raw `.edf` EEG file and prepares it for processing |
| `02_epoch_selection_spectrogram.m` | Visualizes spectrograms for manual epoch rejection |
| `03_filter_and_ica.m` | Applies bandpass and notch filtering, then runs ICA |
| `04_compute_fft_power.m` | Extracts frequency band power using FFT |
| `05_connectivity_dwpli_icoh.m` | Computes dWPLI and iCOH for functional connectivity |
| `06_entropy_sampen.m` | Calculates Sample Entropy on cleaned EEG |

---

## 🚀 Requirements

- **MATLAB R2020b+**
- Signal Processing Toolbox
- EEGLAB (recommended): [https://sccn.ucsd.edu/eeglab/](https://sccn.ucsd.edu/eeglab/)
- [Entropy toolbox](https://www.mathworks.com/matlabcentral/fileexchange/37289-sample-entropy)

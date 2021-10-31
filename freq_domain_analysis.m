function [LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, PSD_welch, VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc] = freq_domain_analysis(RRintervals, r_peaks, fs, size, i, state, fig_nr)
% freq_domain_analysis performs PSD analysis
%
% [LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, PSD_welch, ...
% VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc] = ...
% freq_domain_analysis(RRintervals, r_peaks, fs, size, i, state, fig_nr)
%
% LF_welch: low freqeuncy power with Welch method
% HF_welch: high freqeuncy power with Welch method
% LF_YW: low freqeuncy power with Yule-Walker method
% HF_YW: high freqeuncy power with Yule-Walker method
% LF2HF_welch: ratio between LF_welch and HF_welch
% LF2HF_YW: ratio between LF_YW and HF_YW
% PSD_welch: power spectrum density obtained with welch method
% VLF_welch_pc: percentage of VLF over the total PSD with Welch method
% LF_welch_pc: percentage of LF over the total PSD with Welch method
% HF_welch_pc: percentage of HF over the total PSD with Welch method
% VLF_YW_pc: percentage of VLF over the total PSD with Yule-Walker method
% LF_YW_pc: percentage of LF over the total PSD with Yule-Walker method
% HF_YW_pc: percentage of HF over the total PSD with Yule-Walker method
%
% RRintervals: vector containing the RR distances, in seconds
% r_peaks: vector containing the position of the R peaks, in samples
% fs: ECG sample frequency 
% size: how many sleep state are present in the current subject data
% i: index for plotting purposes
% state: string containing the sleep state fo the subject
% fig_nr: figure number for plotting purposes
%% Pre-processing
% removing the mean value
RRintervals = RRintervals*1000; % expressed in ms

RRintervals=RRintervals-mean(RRintervals);

% detrend
RRintervals = detrend(RRintervals);

% resampling
f_rs = 6;
RRintervals_rs = spline(r_peaks(1:end-1)/fs, RRintervals, (r_peaks/fs:1/f_rs:r_peaks(end-1)/fs-1/f_rs));
%% Check stationarity

[h,pValue] = adftest(RRintervals_rs);
if h==1 && pValue < 0.05
    fprintf('\nThe signal is stationary. \n\n');
end

%% Power spectrum density
% Non-Parametric PSD


desired_resolution = 0.025; % minimum resolution to detect the lower limit of the low frequencies: 0.05Hz
hamming_resolution_factor = 1.3631; % Resolution reduction factor due to the Hamming window
window = fix(hamming_resolution_factor*(f_rs/desired_resolution)); 

overlap = fix(window/2);  %to get a 50% overlap
nfft = 1024; % number of FFT points used to calculate the PSD estimate
[PSD_welch,f_w] = pwelch(RRintervals_rs, hamming(window), overlap, nfft, f_rs);

% Parametric PSD 
AR_order = 16;
[PSD_YW,f_y] = pyulear(RRintervals_rs, AR_order, nfft, f_rs);

%% Power indices
VLF = [0 0.05]; %Very low frequency band
LF = [0.05 0.2]; %Low Frequency band
HF = [0.5 1.5];  %High Frequency band

% frequency vector extraction based on the VLF, LF and HF ranges

f_VLF = and(ge(f_w, VLF(1)), le(f_w, VLF(2)));
f_LF = and(ge(f_w,LF(1)),le(f_w,LF(2))); 
f_HF = and(ge(f_w,HF(1)),le(f_w,HF(2)));

% VLF, LF, HF power extraction from the Welch PSD

VLF_welch = trapz(PSD_welch(f_VLF));
LF_welch = trapz(PSD_welch(f_LF));
HF_welch = trapz(PSD_welch(f_HF));

% frequency vector extraction based on the VLF, LF and HF ranges

f_VLF = and(ge(f_y, VLF(1)), le(f_y, VLF(2)));
f_LF = and(ge(f_y,LF(1)),le(f_y,LF(2))); 
f_HF = and(ge(f_y,HF(1)),le(f_y,HF(2)));

% VLF, LF, HF power extraction from the Yule-Walker PSD

VLF_YW = trapz(PSD_YW(f_VLF)); %#ok<*NASGU> 
LF_YW = trapz(PSD_YW(f_LF));
HF_YW = trapz(PSD_YW(f_HF));

% Percentages of the VLF, LF and HF powers over the total Welch PSD power
VLF_welch_pc = trapz(PSD_welch(f_VLF))/trapz(PSD_welch);
LF_welch_pc = trapz(PSD_welch(f_LF))/trapz(PSD_welch);
HF_welch_pc = trapz(PSD_welch(f_HF))/trapz(PSD_welch);

% Percentages of the VLF, LF and HF powers over the total Yule-Wlaker PSD power
VLF_YW_pc = trapz(PSD_YW(f_VLF))/trapz(PSD_YW);
LF_YW_pc = trapz(PSD_YW(f_LF))/trapz(PSD_YW);
HF_YW_pc = trapz(PSD_YW(f_HF))/trapz(PSD_YW);

% LF to HF ratio with Welch and Yule-Walker estimation
LF2HF_welch = LF_welch/HF_welch;
LF2HF_YW = LF_YW/HF_YW;

fprintf('Welch Analysis:\n Low frequency power spectrum density: \t %f ms^2/Hz;\n High frequency power spectrum density: \t %f ms^2/Hz\n', LF_welch, HF_welch)
fprintf('YW Analysis:\n Low frequency power spectrum density: \t %f ms^2/Hz; \n High frequency power spectrum density: \t %f ms^2/Hz\n', LF_YW, HF_YW)

%% plots

figure(fig_nr + 8);
subplot(2,size,i); semilogy(f_w,PSD_welch); hold on; xline(0.05); xline(0.2); xline(0.5); xline(1.5);
title(strcat(state,' - PSD_Welch RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Welch Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_welch)]; text(0.6,0.8*max(PSD_welch),str,'HorizontalAlignment','left');

subplot(2,size,i+size); semilogy(f_y,PSD_YW); hold on; xline(0.05); xline(0.2); xline(0.5); xline(1.5);
title(strcat(state,' - PSD_YW RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Yule-Walker Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_YW)]; text(0.6,0.8*max(PSD_YW),str,'HorizontalAlignment','left');
linkaxes;

end
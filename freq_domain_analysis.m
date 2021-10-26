function [LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, PSD_welch]=freq_domain_analysis(RRintervals, r_peaks, f, fs, size, i, s) % o r_peaks_fp

%% Pre-processing
% removing the mean value
RRintervals=RRintervals-mean(RRintervals);

% detrend
RRintervals = detrend(RRintervals);

% resampling
f_rs = 6;
RRintervals_rs = interp1(r_peaks(1:end-1)/fs, RRintervals, (r_peaks/fs:1/f_rs:r_peaks(end-1)/fs-1/f_rs));

%% Check stationarity

[h,pValue] = adftest(RRintervals_rs);
if h==1 && pValue < 0.05
    fprintf('\nThe signal is stationary. \n\n')
end
% valutare se mettere una if o un errore
%% Power spectrum density
% Non-Parametric PSD
window = 60;    %60 samples=30 sec
overlap = 30;   %overlap 50%
nfft = 1024;
[PSD_welch,f] = pwelch(RRintervals_rs, hamming(window), overlap, nfft, f_rs);

% Parametric PSD
AR_order = 18;
[PSD_YW,f] = pyulear(RRintervals_rs, AR_order, nfft, f_rs);

%% Power indices
VLF = [0 0.05]; %Very low frequency band
LF = [0.05 0.2]; %Low Frequency band
HF = [0.5 1.5];  %High Frequency band

f_VLF = and(ge(f, VLF(1)), le(f, VLF(2)));
f_LF = and(ge(f,LF(1)),le(f,LF(2))); %ge=greater than or equal to; le=less than or equal to
f_HF = and(ge(f,HF(1)),le(f,HF(2)));

VLF_welch = trapz(PSD_welch(f_VLF));
LF_welch = trapz(PSD_welch(f_LF));
HF_welch = trapz(PSD_welch(f_HF));

VLF_YW = trapz(PSD_YW(f_VLF));
LF_YW = trapz(PSD_YW(f_LF));
HF_YW = trapz(PSD_YW(f_HF));

LF2HF_welch = LF_welch/HF_welch;
LF2HF_YW = LF_YW/HF_YW;

fprintf('Welch Analysis:\n Low frequency power spectrum density: \t %f;\n High frequency power spectrum density: \t %f \n', LF_welch, HF_welch)
fprintf('YW Analysis:\n Low frequency power spectrum density: \t %f; \n High frequency power spectrum density: \t %f \n', LF_YW, HF_YW)

%% plots

figure(8);

subplot(2,size,i); plot(f,PSD_welch); hold on; xline(0.05); xline(0.2); xline(0.5);
title(strcat(s,' - PSD_Welch RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Welch Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_welch)]; text(0.6,0.8*max(PSD_welch),str,'HorizontalAlignment','left');

subplot(2,size,i+size); plot(f,PSD_YW); hold on; xline(0.05); xline(0.2); xline(0.5);
title(strcat(s,' - PSD_YW RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Yule-Walker Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_YW)]; text(0.6,0.8*max(PSD_YW),str,'HorizontalAlignment','left');
linkaxes;

end
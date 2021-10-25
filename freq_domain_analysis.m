function [LF2HF_welch, LF2HF_YW]=freq_domain_analysis(RRintervals, r_peaks_pt, f, fs, size, i, s) % o r_peaks_fp

%% Pre-processing
% removing the mean value
RRintervals=RRintervals-mean(RRintervals);

% detrend
RRintervals = detrend(RRintervals);

% resampling
f_rs = 2;
RRintervals_rs = interp1(r_peaks_pt(1:end-1)/fs, RRintervals, (r_peaks_pt/fs:1/f_rs:r_peaks_pt(end-1)/fs-1/f_rs));

%% Check stationarity

[h,pValue] = adftest(RRintervals_rs);
disp(pValue)
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
VLF = [0 0.04]; %Very low frequency band
LF = [0.04 0.15]; %Low Frequency band
HF = [0.15 0.4];  %High Frequency band

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
%subplot(1,3,1); plot(r_peaks_pt(1:end-1)/fs,RRintervals);
%title('RR_ECG','Interpreter','none'); xlabel('Time [s]'); ylabel('Duration [ms]'); ylim([-150 150]);

subplot(2,size,i); plot(f,PSD_welch);
title(strcat(s,' - PSD_Welch RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Welch Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_welch)]; text(0.6,0.8*max(PSD_welch),str,'HorizontalAlignment','left');

subplot(2,size,i+size); plot(f,PSD_YW);
title(strcat(s,' - PSD_YW RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Yule-Walker Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_YW)]; text(0.6,0.8*max(PSD_YW),str,'HorizontalAlignment','left');


end
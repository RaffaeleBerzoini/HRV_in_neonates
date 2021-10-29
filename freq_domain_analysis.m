function [LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, PSD_welch, VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc]=freq_domain_analysis(RRintervals, r_peaks, f, fs, size, i, s, fig_nr)


%% Pre-processing
% removing the mean value
RRintervals=RRintervals-mean(RRintervals);

% detrend
RRintervals = detrend(RRintervals);

% resampling
f_rs = 6;
RRintervals_rs = spline(r_peaks(1:end-1)/fs, RRintervals, (r_peaks/fs:1/f_rs:r_peaks(end-1)/fs-1/f_rs));
%% Check stationarity

[h,pValue] = adftest(RRintervals_rs);
if h==1 && pValue < 0.05
    fprintf('\nThe signal is stationary. \n\n')
end
% valutare se mettere una if o un errore
%% Power spectrum density
% Non-Parametric PSD

desired_resolution = 0.025; %resolution = f_rs/sample
window = fix(1.3631*(f_rs/desired_resolution));

overlap = fix(window/2);  %overlap 50%
nfft = 1024;
[PSD_welch,f_w] = pwelch(RRintervals_rs, hamming(window), overlap, nfft, f_rs);

% Parametric PSD
AR_order = 18;
[PSD_YW,f_y] = pyulear(RRintervals_rs, AR_order, nfft, f_rs);

%% Power indices
VLF = [0 0.05]; %Very low frequency band
LF = [0.05 0.2]; %Low Frequency band
HF = [0.5 1.5];  %High Frequency band

f_VLF = and(ge(f_w, VLF(1)), le(f_w, VLF(2)));
f_LF = and(ge(f_w,LF(1)),le(f_w,LF(2))); %ge=greater than or equal to; le=less than or equal to
f_HF = and(ge(f_w,HF(1)),le(f_w,HF(2)));

VLF_welch = trapz(PSD_welch(f_VLF));
LF_welch = trapz(PSD_welch(f_LF));
HF_welch = trapz(PSD_welch(f_HF));

f_VLF = and(ge(f_y, VLF(1)), le(f_y, VLF(2)));
f_LF = and(ge(f_y,LF(1)),le(f_y,LF(2))); %ge=greater than or equal to; le=less than or equal to
f_HF = and(ge(f_y,HF(1)),le(f_y,HF(2)));

VLF_YW = trapz(PSD_YW(f_VLF));
LF_YW = trapz(PSD_YW(f_LF));
HF_YW = trapz(PSD_YW(f_HF));

VLF_welch_pc = trapz(PSD_welch(f_VLF))/trapz(PSD_welch);
LF_welch_pc = trapz(PSD_welch(f_LF))/trapz(PSD_welch);
HF_welch_pc = trapz(PSD_welch(f_HF))/trapz(PSD_welch);

VLF_YW_pc = trapz(PSD_YW(f_VLF))/trapz(PSD_YW);
LF_YW_pc = trapz(PSD_YW(f_LF))/trapz(PSD_YW);
HF_YW_pc = trapz(PSD_YW(f_HF))/trapz(PSD_YW);

LF2HF_welch = LF_welch/HF_welch;
LF2HF_YW = LF_YW/HF_YW;

fprintf('Welch Analysis:\n Low frequency power spectrum density: \t %f;\n High frequency power spectrum density: \t %f \n', LF_welch, HF_welch)
fprintf('YW Analysis:\n Low frequency power spectrum density: \t %f; \n High frequency power spectrum density: \t %f \n', LF_YW, HF_YW)

%% plots

figure(fig_nr + 8);
subplot(2,size,i); plot(f_w,PSD_welch); hold on; xline(0.05); xline(0.2); xline(0.5);
title(strcat(s,' - PSD_Welch RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Welch Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_welch)]; text(0.6,0.8*max(PSD_welch),str,'HorizontalAlignment','left');

subplot(2,size,i+size); plot(f_y,PSD_YW); hold on; xline(0.05); xline(0.2); xline(0.5);
title(strcat(s,' - PSD_YW RR_ECG'),'Interpreter','none'); xlabel('Frequency [Hz]'); ylabel('PSD Yule-Walker Method [ms^2/Hz]');
str = ['LF/HF=',num2str(LF2HF_YW)]; text(0.6,0.8*max(PSD_YW),str,'HorizontalAlignment','left');
linkaxes;

end
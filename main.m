%% Clear workspace
clear; clc; close all;

load DATA.mat;
f_sample = 500;
p_1 = LPT_ALLDATA.Ecg{4,1};
% p_1 = p_1(fix(0.75*length(p_1):length(p_1)));  % Se pan tompkins non
% funzia suddividi l'ecg a tratti

% [p_1] = down_sampling(p_1, f_sample, 200);
% f_sample = 200;
t = 0:1/f_sample:(length(p_1)/f_sample)-(1/f_sample);

%% spectrum
p_1_spectrum = abs(fft(p_1,4096));

f = linspace(0,f_sample,length(p_1_spectrum));
w = f/f_sample;

figure;
subplot(1,2,1); plot(t,p_1); title('ECG_s1', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
subplot(1,2,2); plot(f,p_1_spectrum); title('ECG_s1_spectrum', 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');


% [~,Rpeak_s1,delay]=pan_tompkin(p_1,f_sample,0);
% figure;
% plot(t,p_1); hold on; plot((Rpeak_s1)/f_sample, p_1(Rpeak_s1),'ok'); title('ECG_s1_filtered & R_peaks_ECG_s1_filtered', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');

%% 50 Hz notch

% b_50 = [1,-1.618408361976065,1]
% a_50 = [1,-1.359984619672703,0.706141549805827]
% 
% 
% wo = 60/(f_sample/2);  
% bw = wo/2;
% [b_50,a_50] = iirnotch(wo,bw);
% 
% ECG_wo_50 = filter(b_50, a_50, p_1);
wc = 50/(f_sample/2); 
[b,a] = butter(3,wc); 
p1_lp = filter(b, a, p_1);
p_1_spectrum_filt = abs(fft(p1_lp,4096));
figure()
subplot(1,2,1); plot(f,p_1_spectrum); title('ECG_s1_spectrum', 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');
subplot(1,2,2); plot(f,p_1_spectrum_filt); title('ECG_s1_spectrum', 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');


[~,Rpeak_1,delay1]=pan_tompkin(p_1,f_sample,0);
[~,Rpeak_2,delay2]=pan_tompkin(p1_lp,f_sample,0);
qrs_i_raw=pan_tompkin2(p1_lp, Rpeak_2);

figure;
sb(1) = subplot(3,1,1); plot(t,p_1); hold on; plot((Rpeak_1)/f_sample, p_1(Rpeak_1),'ok'); title('Original', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
sb(2) = subplot(3,1,2); plot(t,p1_lp); hold on; plot((Rpeak_1)/f_sample, p1_lp(Rpeak_1),'ok'); title('Filtered', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
sb(3) = subplot(3,1,3); plot(t,p1_lp); hold on; plot((qrs_i_raw)/f_sample, p1_lp(qrs_i_raw),'ok'); title('pan2', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
linkaxes(sb,'x');






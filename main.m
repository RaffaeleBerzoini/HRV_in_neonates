%% Clear workspace
clear; close all; clc;

load DATA.mat;
f_sample = 500;
p_1 = LPT_ALLDATA.Ecg{2,1};  
[p_1] = down_sampling(p_1, f_sample, 200);
f_sample = 200;
t = 0:1/f_sample:(length(p_1)/f_sample)-(1/f_sample);

%% spectrum
p_1_spectrum = abs(fft(p_1,4096));

f = linspace(0,f_sample,length(p_1_spectrum));
w = f/f_sample;

figure;
subplot(1,2,1); plot(t,p_1); title('ECG_s1', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
subplot(1,2,2); plot(f,p_1_spectrum); title('ECG_s1_spectrum', 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');

[~,Rpeak_s1,delay]=pan_tompkin(p_1,f_sample,0);
figure;
plot(t,p_1); hold on; plot((Rpeak_s1)/f_sample, p_1(Rpeak_s1),'ok'); title('ECG_s1_filtered & R_peaks_ECG_s1_filtered', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');


%% Clear workspace
clear; clc; close all;
%% load subject data
subject_number = 1; %Insert a number from 1 to 5

[ecg, active_quiet_state] = getEcg_SleepActivity(subject_number);
f_s = 500;
t = 0:1/f_s:(length(ecg)/f_s)-(1/f_s);
%% spectrum
spectrum = abs(fft(ecg - mean(ecg) ,4096));

f = linspace(0,f_s,length(spectrum));
w = f/f_s; %omega

figure;
subplot(1,2,1); plot(t,ecg); title('ECG', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
subplot(1,2,2); plot(f,spectrum); title('Spectrum', 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');

%% filters application

%% pan-tompkin application

% r_peaks = [];
% 
% for i = 1:fix(length(ecg)/1000)
%     [~,qrs_i_raw,~] = pan_tompkin_mod(ecg(),f_s,0);
%     r_peaks = [r_peaks, qrs_i_raw];
% end

[qrs_amp_raw,r_peaks,delay] = pan_tompkin_mod(ecg,f_s,0);
figure;
plot(t,ecg); hold on; plot((r_peaks)/f_s, ecg(r_peaks),'ok'); title('pan2', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');







%% Clear workspace
clear; clc; close all;
%% load subject data
subject_number = 4; %Insert a number from 1 to 5

[ecg, active_quiet_state] = getEcg_SleepActivity(subject_number);
f_s = 500;
t = 0:1/f_s:(length(ecg)/f_s)-(1/f_s);
%% spectrum
spectrum = abs(fft(ecg - mean(ecg) ,4096));

f = linspace(0,f_s,length(spectrum));
w = f/f_s; %omega

figure(1);
subplot(1,2,1); plot(t,ecg); title('ECG', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
subplot(1,2,2); plot(f,spectrum); title('Spectrum', 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');

%% filters application

filter_order = 3;
fcut = 50;       % cut-off frequency [Hz]
wc = fcut/(f_s/2); % NORMALIZED cut-off frequency
[b,a] = butter(filter_order,wc,'low');
ecg=filtfilt(b, a, ecg);
figure; freqz(b,a,1024,f_s);

spectrum = abs(fft(ecg - mean(ecg) ,4096));

f = linspace(0,f_s,length(spectrum));
figure(5); plot(f, spectrum)

%% pan-tompkin application

[qrs_amp_raw,r_peaks,delay] = pan_tompkin_mod(ecg,f_s,1);

if subject_number == 4
    ecg_flipped = flip(ecg);
    [qrs_amp_raw,r_peaks_flip,delay] = pan_tompkin_mod(ecg_flipped,f_s,1);
    %94141esimo samples flippato, 222200 dritto
    r_peaks = [r_peaks(1:find(r_peaks(:)==222200)), abs(r_peaks_flip(1:find(r_peaks_flip(:)==94141))-length(ecg))]; 
end

figure(34);
plot(t,ecg); hold on; plot((r_peaks)/f_s, ecg(r_peaks),'ok'); title('pan2', 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');


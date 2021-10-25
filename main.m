%% Clear workspace
clear; clc; close all;
%% load subject data
subject_number = 5; % selection of the patient (from 1 to 5)

min_height = [4000, 3900, 6200, 1000, 740]; % valori soglia per ognuno dei pazienti
f_s = 500;

[ecg, active_quiet_state] = getEcg_SleepActivity(subject_number);
state_ecg = get_state_ecg(ecg, active_quiet_state, f_s); 
t0 = 0; %estrarre t0 da state_ecg row2

%% Active vs quiet comparison
for i=1:size(state_ecg,2)
    s = state_ecg{1,i};
    ecg = state_ecg{3,i};
    T = state_ecg{2, i}(2)-state_ecg{2, i}(1); %estrarre T da state_ecg row2
    t = t0:1/f_s:T; 
    
    % Plot of ECG
    
    figure(1);
    subplot(size(state_ecg,2),1,i); plot(t,ecg); title(strcat(s,' -',' ECG'), 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
    
    % spectrum

    spectrum = abs(fft(ecg - mean(ecg),4096));

    f = linspace(0,f_s,length(spectrum));
    w = f/f_s; %omega
    
    % filters application

    filter_order = 3;
    fcut = 50;       % cut-off frequency [Hz]
    wc = fcut/(f_s/2); % NORMALIZED cut-off frequency
    [b,a] = butter(filter_order,wc,'low');
    ecg=filtfilt(b, a, ecg);
    
    figure(2);
    freqz(b,a,1024,f_s); title('Bode Diagrams of the used filter');

    spectrum = abs(fft(ecg - mean(ecg) ,4096));

    f = linspace(0,f_s,length(spectrum));
    
    figure(3);
    subplot(1,size(state_ecg,2),i); plot(f,spectrum); title(strcat(s,' -',' Filtered Spectrum'), 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');

    % R-peaks detection

    [~,r_peaks_pt,~, ~, r_peaks_fp] = r_peaks_detection(ecg, f_s, 0, min_height(subject_number));

    if subject_number == 4
        ecg_flipped = flip(ecg);
        [qrs_amp_raw,r_peaks_flip,delay, ~, ~] = r_peaks_detection(ecg_flipped,f_s,0,0);
        r_peaks_pt = [r_peaks_pt(1:find(r_peaks_pt(:)==222200)-1), abs(r_peaks_flip(1:find(r_peaks_flip(:)==94141))-length(ecg))]; 
    end
    
    if i>1
        close 9;
    end
    
    figure(4);
    sb(1) = subplot(2,size(state_ecg,2),i); plot(t, ecg); hold on; plot((r_peaks_pt)/f_s, ecg(r_peaks_pt),'ok'); title(strcat(s,' -',' Pan-Tompkins Mod'), 'Interpreter', 'none'); ylabel('Amplitude [mV]');
    sb(2) = subplot(2,size(state_ecg,2),i+size(state_ecg,2)); plot(t, ecg); hold on; plot((r_peaks_fp)/f_s, ecg(r_peaks_fp),'ok'); title(strcat(s,' -',' Find Peaks'), 'Interpreter', 'none'); ylabel('Amplitude [mV]');
    xlabel('Time [s]'); 
    linkaxes(sb,'x'); %to use the same axes for the subplots

    % Tachogram
    
    RRintervals = time_intervals(r_peaks_fp, f_s);

    [x, y] = tachogram(RRintervals);
    figure(5);
    subplot(size(state_ecg,2),1,i); plot(x,y); title(strcat(s,' -',' ECG Tachogram')),xlabel('Beats'),ylabel('Time [s]');

    % Histogram

    figure(6);
    % subplot(1,size(state_ecg,2),i); histogram(y,ceil((max(y)-min(y))/(1/f_s))); title(strcat(s,' -',' ECG Histogram of RR peaks')),xlabel('Duration [s]'),ylabel('Occurrence');
    subplot(1,size(state_ecg,2),i); histogram(y,(0.35:(1/f_s):0.8)); title(strcat(s,' -',' ECG Histogram of RR peaks')),xlabel('Duration [s]'),ylabel('Occurrence');
    
    % Scattergram

    figure(7);
    subplot(1,size(state_ecg,2),i); plot(y(1:end-1),y(2:end),'.'); title(strcat(s,' -',' ECG Scattergram')),xlabel('(R-R)_{i}'),ylabel('(R-R)_{i+1}');

    % Time Domain Analysis
    [avgHR, avgHRV, diff, RMSSD, SDNN] = time_domain_analysis(f_s, T, r_peaks_pt, RRintervals);

    % Frequency domain analysis
    [LF2HF_welch, LF2HF_YW] = freq_domain_analysis(RRintervals, r_peaks_fp, f, f_s, size(state_ecg,2), i, s);
end

%% Clear workspace
clear; clc; close all;
%% load subject data

subject_number = 5; % selection of the patient (from 1 to 5)
% ATTENZIONE: per ora quando si avvia il programma bisogna runnarlo per la
% prima volta con il paziente 1

save = true; %true to save parameters

min_height = [4000, 3900, 6200, 1000, 740]; % threshold values for each patient

f_s = 500;

[ecg, active_quiet_state] = getEcg_SleepActivity(subject_number);
state_ecg = get_state_ecg(ecg, active_quiet_state, f_s); 
t0 = 0; % estrarre t0 da state_ecg row2

%% Active vs quiet comparison
fprintf("Subject number: %d", subject_number);

PSDs = [];
RR_intervals = {};
for i=1:size(state_ecg,2)
    s = state_ecg{1,i};
    fprintf("\n\nState: %s\n", s);
    ecg = state_ecg{3,i};
    T = state_ecg{2, i}(2)-state_ecg{2, i}(1); %estrarre T da state_ecg row2
    t = t0:1/f_s:T; 
   
    % Plot of ECG
    
    figure(1);
    subplot(size(state_ecg,2),1,i); plot(t,ecg); title(strcat(s,' -',' ECG'), 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
    linkaxes;
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
    linkaxes

    spectrum = abs(fft(ecg - mean(ecg) ,4096));

    f = linspace(0,f_s,length(spectrum));
    
    figure(3);
    subplot(1,size(state_ecg,2),i); plot(f,spectrum); title(strcat(s,' -',' Filtered Spectrum'), 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');
    linkaxes
    
    % R-peaks detection

    [~,r_peaks_pt,~, ~, r_peaks_fp] = r_peaks_detection(ecg, f_s, 0, min_height(subject_number));

    if subject_number == 4
        ecg_flipped = flip(ecg);
        [qrs_amp_raw,r_peaks_flip,delay, ~, ~] = r_peaks_detection(ecg_flipped,f_s,0,0);
        r_peaks_pt = [r_peaks_pt(1:find(r_peaks_pt(:)==222200)-1), abs(r_peaks_flip(1:find(r_peaks_flip(:)==94141))-length(ecg))]; 
    end

    r_peaks = RR_correction(r_peaks_pt, r_peaks_fp, f_s, subject_number, i);
    
    if i>1
        close 9;
    end
    
    figure(4);
    subplot(size(state_ecg,2),1,i);
    plot(t, ecg); hold on; plot((r_peaks)/f_s, ecg(r_peaks),'ok'); title(strcat(s,' -',' R-peaks extraction'), 'Interpreter', 'none'); ylabel('Amplitude [mV]'); xlabel('Time [s]'); 
    linkaxes;

    % Tachogram
    
    RRintervals = time_intervals(r_peaks, f_s);

    [x, y] = tachogram(RRintervals);
    figure(5);
    subplot(size(state_ecg,2),1,i); plot(x,y); title(strcat(s,' -',' ECG Tachogram')),xlabel('Beats'),ylabel('Time [s]');
    linkaxes;
    % Histogram

    figure(6);
    % subplot(1,size(state_ecg,2),i); histogram(y,ceil((max(y)-min(y))/(1/f_s))); title(strcat(s,' -',' ECG Histogram of RR peaks')),xlabel('Duration [s]'),ylabel('Occurrence');
    subplot(1,size(state_ecg,2),i); histogram(y,(0.35:(1/f_s):0.8)); title(strcat(s,' -',' ECG Histogram of RR peaks')),xlabel('Duration [s]'),ylabel('Occurrence');
    linkaxes;
    % Scattergram

    figure(7);
    subplot(1,size(state_ecg,2),i); plot(y(1:end-1),y(2:end),'.'); title(strcat(s,' -',' ECG Scattergram')),xlabel('(R-R)_{i}'),ylabel('(R-R)_{i+1}');
    linkaxes;
    % Time Domain Analysis and saving parameters in csv file
    
    [avgHR, avgHRV, diff, RMSSD, SDNN, ApEn] = time_domain_analysis(f_s, T, r_peaks, RRintervals);

    if save == true
        if state_ecg{1,i}(1) == 'a'
            state = 1;
        else
            state = 0;
        end
        
        if i==1 && subject_number == 1
            Titles_time = array2table([state,avgHR, avgHRV, diff, RMSSD, SDNN, ApEn, subject_number]);
            Titles_time.Properties.VariableNames(1:8) = {'Active','avgHR','avgHRV','diff','RMSSD','SDNN', 'ApEn', 'subject_number'};
            writetable(Titles_time,'time_parameters.csv');
        else 
            dlmwrite('time_parameters.csv',[state,avgHR, avgHRV, diff, RMSSD, SDNN, ApEn, subject_number],'-append');
        end
    end
    
    % Frequency domain analysis and saving parameters in csv file
    
    [LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, PSD, VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc] = freq_domain_analysis(RRintervals, r_peaks, f, f_s, size(state_ecg,2), i, s);
    
    PSDs = [PSDs, PSD]; %#ok<AGROW> 

    if save == true
        if i==1 && subject_number == 1
            Titles_frequency = array2table([state,LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc, subject_number]);
            Titles_frequency.Properties.VariableNames(1:14) = {'Active','LF_welch','HF_welch','LF_YW','HF_YW','LF2HF_welch','LF2HF_YW', 'VLF_welch_pc', 'LF_welch_pc', 'HF_welch_pc', 'VLF_YW_pc', 'LF_YW_pc', 'HF_YW_pc', 'subject_number'};
            writetable(Titles_frequency,'frequency_parameters.csv'); 
        else
            dlmwrite('frequency_parameters.csv',[state,LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc, subject_number],'-append');
        end
    end

    RR_intervals{1,i}=RRintervals;
    
end

% figure;
% boxplot([RR_intervals{1,1}(1:286), RR_intervals{1,2}(1:286)], {state_ecg{1,1}, state_ecg{1,2}});

% up_limit = min([length(PSDs(:,1)), length(PSDs(:,2))]);
% x = PSDs(:,1);
% y = PSDs(:,2);
% [Cxy,F] = mscohere(x(1:up_limit), y(1:up_limit),hamming(100),80,100,f_s);
% [Pxy,F] = cpsd(x(1:up_limit), y(1:up_limit),hamming(100),80,100,f_s);
% 
% Pxy(Cxy < 0.2) = 0;
% 
% figure;
% plot(F,abs(Pxy));
% xlim([0, 2.5]);
% title('Cross Spectrum Phase')
% xlabel('Frequency (Hz)')
% ylabel('Lag (\times\pi rad)')
% grid



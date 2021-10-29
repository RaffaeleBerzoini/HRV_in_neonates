%% Clear workspace
clear; clc; close all;

%% choose subject(2) to analyze

selected = 0;
request = 0;
while ~selected && request < 2
    list = {'1','2','3','4','5'};
    [subjects,selected] = listdlg('ListString', list, 'ListSize', [120, 90], 'PromptString', "Subject Selection");
    request = request + 1;
end

if ~selected
    error('You have to select at least one subject to procede');
end

min_height = [4000, 3900, 6200, 1000, 740]; % threshold values for RR-peaks extraction
f_s = 500; %sample frequency

filename_appendix = '';
for subject = subjects
    filename_appendix = strcat(filename_appendix,'-', int2str(subject));
end
freq_par_filename = strcat('frequency_parameters',filename_appendix, '.xls');
time_par_filename = strcat('time_parameters',filename_appendix, '.xls');

% deleting all existing file with the same name

if exist(freq_par_filename, 'file')==2
  delete(freq_par_filename);
end

if exist(time_par_filename, 'file')==2
  delete(time_par_filename);
end

%Initialising files header
writecell({'Active','avgHR','avgHRV','diff','RMSSD','SDNN', 'ApEn', 'SampEn', 'subject'}, time_par_filename, Range='A1');
writecell({'Active','LF_welch','HF_welch','LF_YW','HF_YW','LF2HF_welch','LF2HF_YW', 'VLF_welch_pc', 'LF_welch_pc', 'HF_welch_pc', 'VLF_YW_pc', 'LF_YW_pc', 'HF_YW_pc', 'subject'}, freq_par_filename, Range='A1');

for subject = subjects
    [ecg, active_quiet_state] = getEcg_SleepActivity(subject);
    state_ecg = get_state_ecg(ecg, active_quiet_state, f_s); 
    t0 = 0; 

    fprintf("Subject number: %d", subject);

    fig_nr = (subject)*10; % help variable to not overwrite previous subject figures

    for i=1:size(state_ecg,2)
        state = state_ecg{1,i};
        fprintf("\n\nState: %s\n", state);
        ecg = state_ecg{3,i};
        T = state_ecg{2, i}(2)-state_ecg{2, i}(1); %estrarre T da state_ecg row2
        t = t0:1/f_s:T; 
       
        % Plot of ECG
        
        figure(fig_nr + 1);
        subplot(size(state_ecg,2),1,i); plot(t,ecg); title(strcat(state,' -',' ECG'), 'Interpreter', 'none'); xlabel('Time [s]'); ylabel('Amplitude [mV]');
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
        
        figure(fig_nr + 2);
        freqz(b,a,1024,f_s); title('Bode Diagrams of the used filter');
        linkaxes
    
        spectrum = abs(fft(ecg - mean(ecg) ,4096));
    
        f = linspace(0,f_s,length(spectrum));
        
        figure(fig_nr + 3);
        subplot(1,size(state_ecg,2),i); plot(f,spectrum); title(strcat(state,' -',' Filtered Spectrum'), 'Interpreter', 'none'); xlabel('Frequency [Hz]'); ylabel('|X(f)|');
        linkaxes
        
        % R-peaks detection
    
        [~,r_peaks_pt,~, ~, r_peaks_fp] = r_peaks_detection(ecg, f_s, 0, min_height(subject));
    
        if subject == 4
            ecg_flipped = flip(ecg);
            [qrs_amp_raw,r_peaks_flip,delay, ~, ~] = r_peaks_detection(ecg_flipped,f_s,0,0);
            r_peaks_pt = [r_peaks_pt(1:find(r_peaks_pt(:)==222200)-1), abs(r_peaks_flip(1:find(r_peaks_flip(:)==94141))-length(ecg))]; 
        end
    
        r_peaks = RR_correction(r_peaks_pt, r_peaks_fp, f_s, subject, i);
        
        close; %to close a spurious plot of pan_tompkins although putting gr=0;
        
        figure(fig_nr + 4);
        subplot(size(state_ecg,2),1,i);
        plot(t, ecg); hold on; plot((r_peaks)/f_s, ecg(r_peaks),'ok'); title(strcat(state,' -',' R-peaks extraction'), 'Interpreter', 'none'); ylabel('Amplitude [mV]'); xlabel('Time [s]'); 
        linkaxes;
    
        % Tachogram
        
        RRintervals = time_intervals(r_peaks, f_s);
    
        if subject==3
            [r_peaks, RRintervals] = RRint_correction(RRintervals, r_peaks);
        end

        [x, y] = tachogram(RRintervals);
        figure(fig_nr + 5);
        subplot(size(state_ecg,2),1,i); plot(x,y); title(strcat(state,' -',' ECG Tachogram')),xlabel('Beats'),ylabel('Time [s]');
        linkaxes;
        % Histogram
    
        figure(fig_nr + 6);
        % subplot(1,size(state_ecg,2),i); histogram(y,ceil((max(y)-min(y))/(1/f_s))); title(strcat(s,' -',' ECG Histogram of RR peaks')),xlabel('Duration [s]'),ylabel('Occurrence');
        subplot(1,size(state_ecg,2),i); histogram(y,(0.35:(1/f_s):0.8)); title(strcat(state,' -',' ECG Histogram of RR peaks')),xlabel('Duration [s]'),ylabel('Occurrence');
        linkaxes;
        % Scattergram
    
        figure(fig_nr + 7);
        subplot(1,size(state_ecg,2),i); plot(y(1:end-1),y(2:end),'.'); title(strcat(state,' -',' ECG Scattergram')),xlabel('(R-R)_{i}'),ylabel('(R-R)_{i+1}');
        linkaxes;
        % Time Domain Analysis and saving parameters in csv file
        
        [avgHR, avgHRV, diff, RMSSD, SDNN, ApEn, SampEn] = time_domain_analysis(f_s, T, r_peaks, RRintervals);
            % Saving time domain analysis parameters on file
        state_num = 1*(state(1) == 'a');
        writematrix([state_num,avgHR, avgHRV, diff, RMSSD, SDNN, ApEn, SampEn, subject],time_par_filename,'WriteMode','append');       
        
        % Frequency domain analysis and saving parameters in csv file
        
        [LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, PSD, VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc] = freq_domain_analysis(RRintervals, r_peaks, f, f_s, size(state_ecg,2), i, state, fig_nr);
            % Saving frequency domain analysis parameters on file
        writematrix([state_num,LF_welch, HF_welch, LF_YW, HF_YW, LF2HF_welch, LF2HF_YW, VLF_welch_pc, LF_welch_pc, HF_welch_pc, VLF_YW_pc, LF_YW_pc, HF_YW_pc, subject],freq_par_filename,'WriteMode','append');
               
    end
end

response = questdlg('Would you like to perform the statistical analysis?', ...
	'Statistical Analysis', ...
	'Yes', 'No', 'Yes');

if strcmp(response, 'Yes')
    response = questdlg('Would you like to perform the statistical analysis?', ...
	'Statistical Analysis', ...
	'Both', 'Time-domain only', 'Frequency-domain only', 'Both');
    if strcmp(response, 'Frequency-domain only')
        main_freq_stat_analysis(filename_appendix);
    elseif strcmp(response, 'Time-domain only')
        main_time_stat_analysis(filename_appendix);
    else
        main_freq_stat_analysis(filename_appendix);
        main_time_stat_analysis(filename_appendix);
    end
end




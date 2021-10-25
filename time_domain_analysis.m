function [avgHR, avgHRV, diff, RMSSD, SDNN]= time_domain_analysis(f_s, T, r_peaks, RRintervals)
    
    %% Difference between longest and shortest RR interval
    shortestRR = min(RRintervals);
    longestRR = max(RRintervals);
    diff = longestRR-shortestRR; % s

    %% Calculating Average Heart Rate
    
    % Number of R-peaks
    num_R_peaks = length(r_peaks);
    
    %beats per minute
    avgHR = (num_R_peaks*60)/T; % bpm
    
    %% Calculating Average HRV
    avgHRV = mean(RRintervals); % s
    
    %% Calculating RMSSD
    deltaRR = [];
    for i =1:length(RRintervals)-1
        deltaRR = [deltaRR, RRintervals(i)-RRintervals(i+1)];
    end

    sq_intervals = deltaRR .^ 2;
    avg_sq_intervals = mean(sq_intervals);
    RMSSD = sqrt(avg_sq_intervals); % s

    %% Calculating SDNN
    SDNN = std(RRintervals, 1); % s  
    
    %% Results
    fprintf('\nTime domain analysis in the following patients has given the following results: \n Average heart rate (avgHR): \t %.2f bpm \n Average heart rate variance (avgHRV): \t %.2f ms \n Difference between longest and shortest RR interval: \t %.2f ms \n Root Mean Square of the Successive Differences (RMSSD): \t %.2f ms \n Standard Deviation (SDNN): \t %.2f ms \n', avgHR, avgHRV*1000, diff*1000, RMSSD*1000, SDNN*1000);

end
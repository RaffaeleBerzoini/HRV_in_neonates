function [avgHR, avgHRV, diff, RMSSD, SDNN, ApEn, SampEn]= time_domain_analysis(T, r_peaks, RRintervals)
    % time_domain_analysis performs multiple index analysis on the
    % RR-intervals and R-peaks of a subject
    %
    % [avgHR, avgHRV, diff, RMSSD, SDNN, ApEn, SampEn]= time_domain_analysis(T, r_peaks, RRintervals)
    %
    % avgHR: mean bpm over a period of time T
    % avgHRV: mean distance between two R peaks
    % diff: difference between longest and shortest RR interval
    % RMSSD: root mean square of successive differences between normal heartbeats
    % SDNN: the standard deviation of all of the RR intervals
    % ApEn: approximate entropy
    % SampEn: sample entropy


    %% Difference between longest and shortest RR interval
    shortestRR = min(RRintervals);
    longestRR = max(RRintervals);
    diff = longestRR-shortestRR; %seconds

    %% Calculating Average Heart Rate
    
    % Number of R-peaks
    num_R_peaks = length(r_peaks);
    
    % Beats per minute
    avgHR = (num_R_peaks*60)/T; % bpm
    
    %% Calculating Average HRV
    avgHRV = mean(RRintervals); % seconds
    
    %% Calculating RMSSD
    deltaRR = [];
    for i =1:length(RRintervals)-1
        deltaRR = [deltaRR, RRintervals(i)-RRintervals(i+1)]; %#ok<AGROW> 
    end

    sq_intervals = deltaRR .^ 2;
    avg_sq_intervals = mean(sq_intervals);
    RMSSD = sqrt(avg_sq_intervals); % seconds

    %% Calculating SDNN
    SDNN = std(RRintervals, 1); % seconds
    
    %% calculating ApEn

    ApEn = approximateEntropy(RRintervals);
    SampEn = sampen(RRintervals,2,0.2);
    %% Results
    fprintf('\nTime domain analysis in the following patients has given the following results: \n Average heart rate (avgHR): \t %.2f bpm \n Average heart rate variance (avgHRV): \t %.2f ms \n Difference between longest and shortest RR interval: \t %.2f ms \n Root Mean Square of the Successive Differences (RMSSD): \t %.2f ms \n Standard Deviation (SDNN): \t %.2f ms \n Approximate entropy: \t %.2f \n Sample Entropy: \t %.2f', avgHR, avgHRV*1000, diff*1000, RMSSD*1000, SDNN*1000, ApEn, SampEn);

end
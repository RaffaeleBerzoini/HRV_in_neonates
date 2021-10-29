function [time_int] = time_intervals(r_peaks, f_s)
% time_intervals returns the interval in seconds between consecutive R
% peaks
%
% [time_int] = time_intervals(r_peaks, f_s)
% time_int: vector containing the time intervals
% r_peaks: vector containing the position, in samples, of the R peaks
% f_s: sampling frequency

    r_peaks_time = r_peaks/f_s; % convert r_peaks sample vector in r_peaks time vector.
    time_int = zeros(length(r_peaks)-1, 1);
    for i = 1:length(r_peaks_time)-1
        time_int(i) = r_peaks_time(i+1) - r_peaks_time(i);
    end
    
end
function [time_int] = time_intervals(r_peaks, f_s)

r_peaks_time = r_peaks/f_s; % convert r_peaks sample vector in r_peaks time vector.
time_int = zeros(length(r_peaks)-1, 1);
for i = 1:length(r_peaks_time)-1
    time_int(i) = r_peaks_time(i+1) - r_peaks_time(i);
end
end
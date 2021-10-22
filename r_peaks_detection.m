function [qrs_amp_pt,qrs_i_pt,delay_pt, qrs_amp_fp, qrs_i_fp] = r_peaks_detection(ecg, f_s, gr, min_peak_height)

[qrs_amp_pt,qrs_i_pt,delay_pt] = pan_tompkin_mod(ecg,f_s,gr);
[qrs_amp_fp, qrs_i_fp] = findpeaks(ecg, "MinPeakHeight", min_peak_height);

end
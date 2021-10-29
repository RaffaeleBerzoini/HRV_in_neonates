function clean_R_peaks = R_peaks_correction(peaks_pt, peaks_fp, fs, subject_number, i)
% clean_R_peaks = R_peaks_correction(peaks_pt, peaks_fp, fs,
% subject_number, i) removes all the extra peaks detected by the
% r-peaks extraction algorithms
%
% clean_R_peaks = R_peaks_correction(peaks_pt, peaks_fp, fs, subject_number, i)
% clean_R_peaks: vector containing the corrected peaks position in samples
% peaks_pt: R peaks detected by pan_tompkin_mod, in samples
% peaks_fp: R peaks detected by findpeaks(), in samples
% fs: sampling frequency
% subject number: subject's ecg to correct
% i: sequential index to determine which sleep state ecg to correct

    peaks_to_use = {'fp', 'fp', 'fp';
                    'fp', 'pt', 'fp';
                    'fp', 'fp', 'fp';
                    'fp', 'fp', 'fp';
                    'fp', 'fp', 'fp';};  

    removal = {'none', 'none', 'none';
                   'none', 'none', 'none';
                    'none', 'none', 'none';
                    'none', [1.74; 1.838; 2.268; 2.332; 2.484; 2.528; 2.626; 7.7; 11.352; 84.61; 84.654; 85.186], 'none';
                    [0.028], [160.31], 'none'};
   
    clean_R_peaks = peaks_fp;

    if strcmp(peaks_to_use{subject_number, i}, 'pt')
        clean_R_peaks = peaks_pt;
    end
    
    if ~strcmp(removal{subject_number, i}, 'none')
        to_remove = removal{subject_number, i}; %in seconds
        for j = 1:length(to_remove)
            index = clean_R_peaks/fs == to_remove(j);
            clean_R_peaks(index) = []; 
        end
    end

    clean_R_peaks = unique(clean_R_peaks);
    clean_R_peaks = sort(clean_R_peaks);
end
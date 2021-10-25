function clean_RR = RR_correction(peaks_pt, peaks_fp, fs, subject_number, i)

    peaks_to_use = {'fp', 'fp', 'fp';
                    'fp', 'pt', 'fp';
                    'fp', 'fp', 'fp';
                    'fp', 'fp', 'fp';
                    'fp', 'fp', 'fp';};  

    corrections = {'none', 'none', 'none';
                   'none', 'none', 'none';
                    'none', 'none', 'none';
                    'none', [1.74; 2.268; 2.332; 2.484; 2.528; 2.626; 7.7; 11.352; 84.654], 'none';
                    [0.028], [160.31], 'none'};
   
    clean_RR = peaks_fp;

    if peaks_to_use{subject_number, i} == 'pt'
        clean_RR = peaks_pt;
    end
    
    if corrections{subject_number, i} ~= 'none'
        to_remove = corrections{subject_number, i}; %in seconds
        for j = 1:length(to_remove)
            index = find(clean_RR/fs == to_remove(j));
            clean_RR(index) = []; 
        end
    end
    clean_RR = unique(clean_RR);
end
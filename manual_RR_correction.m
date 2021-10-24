function clean_RR = manual_RR_correction(peaks, to_remove, fs)

    % to_remove = [1.74; 2.332; 2.484; 2.528; 2.626; 7.7; 11.352; 84.654]; %in seconds 
    clean_RR = peaks;
    for i = 1:length(to_remove)
        index = find(clean_RR/fs == to_remove(i));
        clean_RR(index) = []; 
    end
end
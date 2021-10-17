function qrs_i_raw=pan_tompkin2(ecg, R_peak)

qrs_i_raw = [R_peak(1)]; %initializing vector

for i = 2:length(R_peak) %patient 3: remove last element for cycle(i.e.: i = 2:length(R_peak)-1)
    dist = R_peak(i) - R_peak(i-1);
    dist = fix(dist/3);
    qrs_i_raw = [qrs_i_raw, find(ecg(R_peak(i)-dist:R_peak(i)+dist)==max(ecg(R_peak(i)-dist:R_peak(i)+dist)))+R_peak(i)-dist-1];
end
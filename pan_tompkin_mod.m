% function qrs_i_raw=pan_tompkin2(ecg, R_peak)
function [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin_mod(ecg,fs,gr)

[qrs_amp_raw,R_peak,delay] = pan_tompkin(ecg,fs,gr);

qrs_i_raw = []; %initializing vector

i=1;
dist = R_peak(i+1) - R_peak(i);
dist = fix(dist/3);
qrs_i_raw = [qrs_i_raw, find(ecg(1:R_peak(i)+dist)==max(ecg(1:R_peak(i)+dist)))];

for i = 2:length(R_peak)-1 %patient 3: remove last element for cycle(i.e.: i = 2:length(R_peak)-1)
    dist = R_peak(i) - R_peak(i-1);
    dist = fix(dist/3);
    qrs_i_raw = [qrs_i_raw, find(ecg(R_peak(i)-dist:R_peak(i)+dist)==max(ecg(R_peak(i)-dist:R_peak(i)+dist)))+R_peak(i)-dist-1];
end
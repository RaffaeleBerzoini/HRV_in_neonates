function [ecg, active_quiet_state] = getEcg_SleepActivity(subject_number)
%   getEcg_SleepActivity returns the ecg and the sleep activity records of a
%   subject from the file provided
%
%   ecg: vector containing the ecg samples
%   active_quite: vector containing the sleep state of the subject
%INPUT
%   patient_number: number of the row containing subject data

load DATA.mat;
ecg = LPT_ALLDATA.Ecg{subject_number,1};
active_quiet_state = LPT_ALLDATA.SS_baseline{subject_number,1};

end


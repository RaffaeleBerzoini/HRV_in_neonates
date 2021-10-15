function [new_signal] = down_sampling(signal, fs, new_fs)
%UP_DOWN_SAMPLING Summary of this function goes here
%   Detailed explanation goes here
if ~isvector(signal)
  error('signal must be a row or column vector');
end

n_samples = (new_fs/fs)*length(signal);
interval = fix(length(signal)/n_samples);

new_signal = signal(1:interval:end);

end


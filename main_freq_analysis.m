%%
clc; close all; clear;

%% loading data

params_freq = readtable('frequency_parameters.csv');
params_freq = table2array(params_freq);

params_time = readtable('time_parameters.csv');
params_time = table2array(params_time);

LF_active = params_freq(:, 2); LF_active = LF_active(params_freq(:,1) == 1);
HF_active = params_freq(:, 3); HF_active = HF_active(params_freq(:,1) == 1);

LF_quiet = params_freq(:, 2); LF_quiet = LF_quiet(params_freq(:,1) == 0);
HF_quiet = params_freq(:, 3); HF_quiet = HF_quiet(params_freq(:,1) == 0);

figure;
scatter(LF_active, HF_active, 'red'); hold on; grid on;
scatter(LF_quiet, HF_quiet, 'blue'); legend('Active', 'Quiet'); xlabel('LF'); ylabel('HF');
xlim([0 0.65]); ylim([0 0.65]);

%%
clc; close all; clear;

%%

params = readtable('time_parameters.csv');
active = params{:,"Active"}==1;
quiet = params{:, "Active"}==0;
variables = params.Properties.VariableNames;

filename = 'time_analysis.xls';
if exist(filename, 'file')==2
  delete(filename);
end

writecell({'QS'}, filename, Range='D1');
writecell({'AS'}, filename, Range='I1');
writecell({'Mean', 'SD', 'Median', 'IQR'}, filename, Range='B2');
writecell({'Mean', 'SD', 'Median', 'IQR'}, filename, Range='G2');
writecell(variables(2:end)', filename, Range='A3:A9');
writecell({'MWW-p.Value'}, filename, Range='L2');

row = 3;
for i = 2:size(params, 2)-1
    quiet_vals = [mean(params{quiet, i}), std(params{quiet, i}), median(params{quiet, i}), iqr(params{quiet, i})];
    active_vals = [mean(params{active, i}), std(params{active, i}), median(params{active, i}), iqr(params{active, i})];
    [p, h] = ranksum(params{quiet, i},params{active, i});
    writematrix([p], filename, Range=strcat('L', int2str(row)));
    writematrix(quiet_vals, filename, Range=strcat('B', int2str(row)));
    writematrix(active_vals, filename, Range=strcat('G', int2str(row)));
    row = row + 1;
end


%

%[p,h] = ranksum(x,y) % h == 1 reject the null hypothesis that data in x and y are samples from continuous distributions with equal medians


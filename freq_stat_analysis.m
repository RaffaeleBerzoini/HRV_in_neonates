function freq_stat_analysis(file_appendix) 
    % freq_stat_analysis performs statistical analysis on the frequecy
    % parameters obtained from the HRV
    %
    % freq_stat_analysis(file_appendix) 
    %
    % void function, the results are provided via an .xls file
    %
    % file_appendix: string containing the appendix for the output .xls
    % file
    
    % read the parameters file built in main

    params = readtable(strcat('frequency_parameters', file_appendix));
    active = params{:,"Active"}==1;
    quiet = params{:, "Active"}==0;
    variables = params.Properties.VariableNames;
    
    % delete file with same name

    filename = strcat('frequency_analysis', file_appendix, '.xls');
    if exist(filename, 'file')==2
      delete(filename);
    end
    
    % write on file column's headers

    writecell({'QS'}, filename, Range='D1');
    writecell({'AS'}, filename, Range='I1');
    writecell({'Mean', 'SD', 'Median', 'IQR'}, filename, Range='B2');
    writecell({'Mean', 'SD', 'Median', 'IQR'}, filename, Range='G2');
    writecell(variables(2:end)', filename, Range='A3:A14');
    writecell({'MWW-p.Value'}, filename, Range='L2');
    
    % write on file all the statistical results obtained from the
    % parameters
    row = 3;
    for i = 2:size(params, 2)-1
        quiet_vals = [mean(params{quiet, i}), std(params{quiet, i}), median(params{quiet, i}), iqr(params{quiet, i})];
        active_vals = [mean(params{active, i}), std(params{active, i}), median(params{active, i}), iqr(params{active, i})];
        [p, ~] = ranksum(params{quiet, i},params{active, i});
        writematrix([p], filename, Range=strcat('L', int2str(row))); %#ok<NBRAK> 
        writematrix(quiet_vals, filename, Range=strcat('B', int2str(row)));
        writematrix(active_vals, filename, Range=strcat('G', int2str(row)));
        row = row + 1;
    end
end


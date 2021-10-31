function time_stat_analysis(file_appendix)
    % time_stat_analysis performs statistical analysis on the time
    % parameters obtained from the HRV
    %
    % time_stat_analysis(file_appendix) 
    %
    % void function, the results are provided via an .xls file
    %
    % file_appendix: string containing the appendix for the output .xls
    % file

    % read the parameters file built in main

    params = readtable(strcat('time_parameters', file_appendix));
    active = params{:,"Active"}==1;
    quiet = params{:, "Active"}==0;
    variables = params.Properties.VariableNames;

    % delete file with same name
    
    filename = strcat('time_analysis', file_appendix, '.xls');
    if exist(filename, 'file')==2
    delete(filename);
    end

    % write on file column's headers
    
    writecell({'QS'}, filename, Range='D1');
    writecell({'AS'}, filename, Range='J1');
    writecell({'Mean', 'SD', 'Median', 'IQR', strcat('N(',char(956),',',char(955),'^2',')')}, filename, Range='B2');
    writecell({'Mean', 'SD', 'Median', 'IQR', strcat('N(',char(956),',',char(955),'^2',')')}, filename, Range='H2');
    writecell(variables(2:end)', filename, Range='A3:A9');
    writecell({'p.Value'}, filename, Range='N2');
    writecell({'MWW/ttest'}, filename, Range='O2');
    
    
    % write on file all the statistical results obtained from the
    % parameters
    
    row = 3;
    for i = 2:size(params, 2)-1
        quiet_vals = [mean(params{quiet, i}), std(params{quiet, i}), median(params{quiet, i}), iqr(params{quiet, i})];
        active_vals = [mean(params{active, i}), std(params{active, i}), median(params{active, i}), iqr(params{active, i})];
        
        warning('off') % to suppress the message "P is greater than the largest tabulated value, returning 0.5."
        if size(params, 1) >= 4 %tests non conductable if less than 4 observations are available
            [hq_norm,~] = lillietest(params{quiet, i}); % h = 1 data are not normally distributed
            [ha_norm,~] = lillietest(params{active, i});
            
            if ~hq_norm && ~ha_norm %if both are normally distributed
                test_used = 'ttest';
                [~, p] = ttest2(params{quiet, i}, params{active, i}); % h==1 different distribution
            else
                test_used = 'MWW';
                [p, ~] = ranksum(params{quiet, i},params{active, i}); % h==1 different distribution
            end
            
            if hq_norm
                writematrix([0], filename, Range=strcat('F', int2str(row))) %#ok<*NBRAK> 
            else
                writematrix([1], filename, Range=strcat('F', int2str(row)))
            end
            if ha_norm
                writematrix([0], filename, Range=strcat('L', int2str(row)))
            else
                writematrix([1], filename, Range=strcat('L', int2str(row)))
            end
            
            writematrix([test_used], filename, Range=strcat('O', int2str(row)));
            writematrix([p], filename, Range=strcat('N', int2str(row))); 
        end
        writematrix(quiet_vals, filename, Range=strcat('B', int2str(row)));
        writematrix(active_vals, filename, Range=strcat('H', int2str(row)));
    
        row = row + 1;
    end
end

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
    writecell({'AS'}, filename, Range='I1');
    writecell({'Mean', 'SD', 'Median', 'IQR'}, filename, Range='B2');
    writecell({'Mean', 'SD', 'Median', 'IQR'}, filename, Range='G2');
    writecell(variables(2:end)', filename, Range='A3:A9');
    writecell({'MWW-p.Value'}, filename, Range='L2');
    
    % write on file all the statistical results obtained from the
    % parameters
    
    row = 3;
    for i = 2:size(params, 2)-1
        quiet_vals = [mean(params{quiet, i}), std(params{quiet, i}), median(params{quiet, i}), iqr(params{quiet, i})];
        active_vals = [mean(params{active, i}), std(params{active, i}), median(params{active, i}), iqr(params{active, i})];
        
        warning('off') % to suppress the message "P is greater than the largest tabulated value, returning 0.5."
        [hq_norm,~] = lillietest(params{quiet, i}); % h = 1 data are not normally distributed
        [ha_norm,~] = lillietest(params{active, i});
        fprintf('\nvar: %s, h_q_not_norm = %d, h_a_not_norm = %d', variables{i}, hq_norm, ha_norm);
        if ~hq_norm && ~ha_norm %if both are normally distributed
            [h, p] = ttest2(params{quiet, i}, params{active, i});% null hypothesis that the data in vectors x and y comes from independent random samples
            if h == 0
                fprintf('  not indipendent, tt\n');
            else
                fprintf(' indipendent, tt, p:%f\n', p);
            end
        else
            [p, h] = ranksum(params{quiet, i},params{active, i});
            if h == 1
                fprintf('  indipendent, ww, p:%f\n', p);
            else
                fprintf(' not indipendent ww\n');
            end
        end
        
        [p, ~] = ranksum(params{quiet, i},params{active, i});
        writematrix([p], filename, Range=strcat('L', int2str(row))); %#ok<NBRAK> 
        writematrix(quiet_vals, filename, Range=strcat('B', int2str(row)));
        writematrix(active_vals, filename, Range=strcat('G', int2str(row)));
    
        row = row + 1;
    end
end

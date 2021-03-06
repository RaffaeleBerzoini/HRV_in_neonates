function [state_ecg] = get_state_ecg(ecg, active_quiet_state, fs)
%   get_state_ecg returns the time interval of each sleep state of a
%   subject with the corresponding ecg interval
%
%   [state_ecg] = get_state_ecg(ecg, active_quiet_state)
%   Return a cell with
%   -row 1: active/quiet state in string format
%   -row 2: time interval of the state
%   -row 3: subset of the ecg corresponding to the time interval

%#ok<*AGROW>
state_ecg = {};
active_quiet_state = active_quiet_state{1,1};
for i = 1:length(active_quiet_state)/3
    if active_quiet_state(i*3) == 1
        state_ecg{1,i} = 'quite';  % 0 == quite
    else
        state_ecg{1,i} = 'active'; % 1 == active
    end
    state_ecg{2,i} = [active_quiet_state((i-1)*3+1); active_quiet_state((i-1)*3+2)]; %Insertion of the time interval of the state
    state_ecg{3,i} = ecg(active_quiet_state((i-1)*3+1)*fs+1:active_quiet_state((i-1)*3+2)*fs+1); %Insertion of the ecg interval of the state
    
end

end
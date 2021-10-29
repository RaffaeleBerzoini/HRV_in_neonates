function [Rsample, RRintervals] = RRinterval_correction(OLDintervals, OLDpeaks, threshold)
% [Rsample, RRintervals] = RRinterval_correction(OLDintervals, OLDpeaks)
% adds fictitious beats where the distance between two peaks is higher than
% a threshold.
%
% Rsample: vector with the corrected R peaks positions, in samples
% RRintervals: vector with the RR intervals, in seconds
%
% OLDintervals: the RR intervals to correct
% OLDpeaks: the R peaks to correct
% threshold: minimum distance between two R peaks

a = OLDintervals>=threshold;

RRintervals = [];
Rsample = [];
for i=1:length(OLDintervals)

    if a(i) == 1
        x = fix((OLDpeaks(i+1) - OLDpeaks(i))/2);
        y = OLDpeaks(i)+x;
        Rsample = [Rsample, OLDpeaks(i)]; %#ok<*AGROW> 
        Rsample = [Rsample, y];
        RRintervals = [RRintervals, OLDintervals(i)/2];
        RRintervals = [RRintervals, OLDintervals(i)/2];
    elseif a(i) == 0
        Rsample = [Rsample, OLDpeaks(i)];
        RRintervals = [RRintervals, OLDintervals(i)];
    end

end

Rsample = [Rsample, OLDpeaks(end)];

end

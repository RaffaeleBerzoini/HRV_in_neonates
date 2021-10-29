function [Rsample, RRintervals] = RRint_correction(OLDintervals, OLDpeaks)

a = OLDintervals>=0.78

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

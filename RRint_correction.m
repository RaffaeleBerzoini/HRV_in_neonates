function [RRsample, RRintervals] = RRint_correction(OLDintervals, OLDpeaks)

a = OLDintervals>0.8
RRintervals = [];
RRsample = [];
for i=1:length(OLDintervals)

    if a(i) == 1
        x = fix((OLDpeaks(i+1) - OLDpeaks(i))/2);
        y = OLDpeaks(i)+x;
        RRsample = [RRsample, OLDpeaks(i)];
        RRsample = [RRsample, y];
        RRintervals = [RRintervals, OLDintervals(i)/2];
        RRintervals = [RRintervals, OLDintervals(i)/2];
    elseif a(i) == 0
        RRsample = [RRsample, OLDpeaks(i)];
        RRintervals = [RRintervals, OLDintervals(i)];
    end

end

RRsample = [RRsample, OLDpeaks(end)];
a=size(RRsample)
b=size(RRintervals)

end

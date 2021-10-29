function [x, y] = tachogram(time_intervals)
%TACHOGRAM construct two vectors for tachogram plotting
%   
% [x, y] = tachogram(time_intervals)
%
% x: vector to use for the x-axis
% y: vector to use for the y-axis
%
% time_intervals: vector containing the RR distances, in seconds

x = 1:1:length(time_intervals);
y = time_intervals;

end


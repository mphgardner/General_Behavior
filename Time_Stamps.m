function [Times] = Time_Stamps(Time_Series, Events, pre, post, varargin)
%This function takes a time series vector and events input and
%finds the time stamps around each event. Time stapms are then stored in a cell array
%Pre should be a negative number. Note that the time units should be
%the same for all inputs Time_Series, Events, pre and post

if isempty(varargin)

Times = arrayfun(@(x) Time_Series(Time_Series - x > pre & Time_Series - x <= post) - x, Events, 'UniformOutput', false);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This varargin saves the values as a single data type (32 bit) rather than double(64
%bit). Note that if the size of the window to be saved gets too large,
%single data type will start losing precision

elseif any(strcmpi(varargin{1},'Single')) 
    
Times = arrayfun(@(x) single(Time_Series(Time_Series - x > pre & Time_Series - x <= post) - x), Events, 'UniformOutput', false);

end


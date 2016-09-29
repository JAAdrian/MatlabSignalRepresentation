classdef AbstractSignal < handle
%ABSTRACTSIGNAL <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% AbstractSignal Properties:
%	propA - <description>
%	propB - <description>
%
% AbstractSignal Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  29-Sep-2016 17:35:47
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (Access = public)
    Signal;
    SampleRate;
end

properties (Access = public, Abstract)
    NumChannels;
    Duration;
    NumSamples;
end



methods (Abstract)
    [hf, ha] = plot(self);
end


end


% End of file: AbstractSignal.m

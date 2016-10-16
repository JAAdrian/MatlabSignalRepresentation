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

properties (SetAccess = protected, GetAccess = public, Abstract)
    NumChannels;
    Duration;
    NumSamples;
end



methods
    function [self] = AbstractSignal(signalOrObject, sampleRate)
        if ~nargin
            return;
        end
        narginchk(1, 2);
        validateattributes(signalOrObject, ...
            {'numeric', 'Signal.AbstractClasses.AbstractSignal'}, ...
            {'2d', 'nonempty'}, ...
            mfilename, ...
            'Signal Object or Vector or Matrix', ...
            1 ...
            );
        
        if nargin > 1
            validateattributes(sampleRate, ...
                {'numeric'}, ...
                {'scalar', 'integer', 'positive', 'nonempty', 'nonnan', ...
                'finite', 'real'}, ...
                mfilename, ...
                'Sampling Rate in Hz', ...
                2 ...
                );
        end
    end
end

methods (Abstract)
    [] = compute(self);
    [hf, ha] = plot(self);
    
    [] = sound(self);
    [] = soundsc(self);
end

methods (Access = protected, Abstract)
    [yesNo] = AmIReady(self);
end

end


% End of file: AbstractSignal.m

classdef TimeDomainSignal < AbstractSignal
%TIMEDOMAINSIGNAL <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% TimeDomainSignal Properties:
%	propA - <description>
%	propB - <description>
%
% TimeDomainSignal Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  29-Sep-2016 17:36:51
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (Access = public)
    NumSamples;
    Duration;
    
    NumChannels;
end

properties (Access = protected, Dependent)
    TimeVector;
end


methods
    function [self] = TimeDomainSignal(signalVector, sampleRate)
        if ~nargin
            return;
        end
        narginchk(2, 2);
        validateattributes(signalVector, ...
            {'numeric'}, ...
            {'2d', 'nonempty', 'nonsparse', 'finite', 'nonnan'}, ...
            mfilename, ...
            'Signal Vector or Matrix', ...
            1 ...
            );
        validateattributes(sampleRate, ...
            {'numeric'}, ...
            {'scalar', 'integer', 'positive', 'nonempty', 'nonnan', ...
             'finite', 'real'}, ...
            mfilename, ...
            'Sampling Rate in Hz', ...
            2 ...
            );
        
        self.Signal     = signalVector;
        self.SampleRate = sampleRate; 
    end
    
    function [ha] = plot(self, duration)
        if nargin < 2 || isempty(duration)
            duration = [0, self.Duration];
        end
        validateattributes(duration, ...
            {'numeric'}, ...
            {'vector', 'nonnegative', 'increasing',  'numel', 2, ...
             'nonempty', 'nonnan', 'finite', 'real'} ...
            )
        duration = round(duration * self.SampleRate);
        duration = (duration(1) : duration(end)) + 1;
        
        ha = axes;
        plot(ha, self.TimeVector(duration), self.Signal(duration, :));
        
        title('Waveform of the Time Domain Signal');
        xlabel('Time in s');
        ylabel('Amplitude');
        
        if self.NumChannels > 1
            legendText = arrayfun(...
                @(x) sprintf('Channel %d', x), ...
                1:self.NumChannels, ...
                'uni', false);
            legend(ha, legendText, 'location', 'best');
        end
    end
    
    function [val] = get.TimeVector(self)
        val = (0 : self.NumSamples-1).' / self.SampleRate;
    end
    
    
    
    function [val] = get.NumSamples(self)
        val = size(self.Signal, 1);
    end
    
    function [val] = get.Duration(self)
        val = self.NumSamples / self.SampleRate;
    end
    
    function [val] = get.NumChannels(self)
        val = size(self.Signal, 2);
    end
end


end


% End of file: TimeDomainSignal.m

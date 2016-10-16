classdef TimeDomain < Signal.AbstractClasses.AbstractSignal
%TimeDomain <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% TimeDomain Properties:
%	propA - <description>
%	propB - <description>
%
% TimeDomain Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  29-Sep-2016 17:36:51
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (SetAccess = protected, GetAccess = public)
    NumSamples;
    Duration;
    
    NumChannels;
end

properties (Access = protected, Dependent)
    TimeVector;
end


methods
    function [self] = TimeDomain(varargin)
        self@Signal.AbstractClasses.AbstractSignal(varargin{:});
        
        switch class(varargin{1})
            case 'Signal.TimeDomain'
                self = varargin{1};
            case 'Signal.FrequencyDomain'
                objFreq = varargin{1};
                
                self.freq2time(objFreq);
            case 'Signal.STFT'
                error('Not yet implemented');
            case 'Signal.PSD'
                error('Not yet implemented');
            case 'double'
                self.Signal     = varargin{1};
                self.SampleRate = varargin{2};
                
                [self.NumSamples, self.NumChannels] = size(self.Signal);
                self.Duration = self.NumSamples / self.SampleRate;
            otherwise
                error('Signal class not recognized!');
        end
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
        duration = (duration(1) : duration(end)-1) + 1;
        
        ha = axes;
        plot(ha, self.TimeVector(duration), self.Signal(duration, :));
        axis tight;
        
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
    
    function [] = sound(self)
        sound(self.Signal, self.SampleRate);
    end
    
    function [] = soundsc(self)
        soundsc(self.Signal, self.SampleRate);
    end
    
    
    function [] = resample(self, desiredSampleRate)
        validateattributes(desiredSampleRate, ...
            {'numeric'}, ...
            {'scalar', 'integer', 'positive', 'nonempty', 'nonnan', ...
             'finite', 'real'} ...
            );
        
        self.Signal = resample(self.Signal, desiredSampleRate, self.SampleRate);
        self.SampleRate = desiredSampleRate;
    end
    
    
    function [val] = get.TimeVector(self)
        val = (0 : self.NumSamples-1).' / self.SampleRate;
    end
end

methods (Access = protected)
    function [yesNo] = AmIReady(self) %#ok<MANU>
        yesNo = true;
    end
    
    function [] = freq2time(self, objFreq)
        self.SampleRate = objFreq.SampleRate;
        
        freqSignal = [objFreq.Signal; conj(objFreq.Signal(end-1:-1:2, :))];
        self.Signal = ifft(freqSignal, objFreq.FftSize, 'symmetric');
        
        [self.NumSamples, self.NumChannels] = size(self.Signal);
        self.Duration = self.NumSamples / self.SampleRate;
    end    
end

end


% End of file: TimeDomain.m

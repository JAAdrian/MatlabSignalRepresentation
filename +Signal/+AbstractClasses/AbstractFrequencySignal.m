classdef AbstractFrequencySignal < Signal.AbstractClasses.AbstractSignal
%ABSTRACTFREQUENCYSIGNAL <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% AbstractFrequencySignal Properties:
%	propA - <description>
%	propB - <description>
%
% AbstractFrequencySignal Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  29-Sep-2016 21:06:20
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (Access = protected)
    TimeDomainSignal;
end

properties (Access = protected, Dependent)
    FrequencyVector;
    WindowedSignal;
end

properties (Access = protected, Abstract)
    Window;
end

properties (Access = public, Dependent)
    NumSamples;
    Duration;
    
    NumChannels;
end

properties (Access = public, Abstract)
    FftSize;
    WindowFunction;
end


methods
    function [self] = AbstractFrequencySignal(signal, sampleRate)
        if ~nargin
            return;
        end
        narginchk(1, 2)

        switch class(signal)
            case 'Signal.TimeDomain'
                % do nothing
            case 'double'
                signal = Signal.TimeDomain(signal, sampleRate);
            otherwise
                error('Signal class not recognized!');
        end 
        
        self.TimeDomainSignal = signal.Signal;
        self.SampleRate = signal.SampleRate;
    end
    
    function [] = sound(self)
        sound(self.TimeDomainSignal, self.SampleRate);
    end
    
    function [] = soundsc(self)
        soundsc(self.TimeDomainSignal, self.SampleRate);
    end
    
    
    
    function [val] = get.WindowedSignal(self)
        val = bsxfun(@times, self.TimeDomainSignal, self.Window);
    end
    
    function [val] = get.FrequencyVector(self)
        val = linspace(0, self.SampleRate/2, self.FftSize/2+1).';
    end
    
    function [val] = get.NumSamples(self)
        val = size(self.TimeDomainSignal, 1);
    end
    
    function [val] = get.Duration(self)
        val = self.NumSamples / self.SampleRate;
    end
    
    function [val] = get.NumChannels(self)
        val = size(self.TimeDomainSignal, 2);
    end
end


end


% End of file: AbstractFrequencySignal.m

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


properties (Access = protected, Dependent)
    FrequencyVector;
end

properties (Access = protected, Abstract)
    Window;
end

properties (SetAccess = protected, GetAccess = public)
    NumSamples;
    Duration;
    
    NumChannels;
end

properties (Access = public)
    FftSize = 512;
    WindowFunction = @(x) ones(x, 1);
end


methods
    function [self] = AbstractFrequencySignal(signal, sampleRate)
        if ~nargin
            return;
        end
        narginchk(1, 2)
        
%         validateattributes();
        
%         if nargin > 1
%             validateattributes();
%         end

        switch class(signal)
            case 'Signal.TimeDomain'
                % do nothing
            case 'double'
                signal = Signal.TimeDomain(signal, sampleRate);
            otherwise
                error('Signal class not recognized!');
        end
        
        self.SampleRate = signal.SampleRate;
        
        self.NumSamples  = signal.NumSamples;
        self.Duration    = signal.Duration;
        self.NumChannels = signal.NumChannels;
        
        self.compute(signal.Signal);
    end
    
    function [] = sound(self)
        sound(self.TimeDomainSignal, self.SampleRate);
    end
    
    function [] = soundsc(self)
        soundsc(self.TimeDomainSignal, self.SampleRate);
    end
    
    function [val] = get.FrequencyVector(self)
        val = linspace(0, self.SampleRate/2, self.FftSize/2+1).';
    end
    
    function [] = set.WindowFunction(self, windowFunction)
        validateattributes(windowFunction, ...
            {'function_handle'}, ...
            {'nonempty'} ...
            );
        
        self.WindowFunction = windowFunction;
    end
    
    function [] = set.FftSize(self, fftSize)
        validateattributes(fftSize, ...
            {'numeric'}, ...
            {'scalar', 'positive', 'even', ...
            'nonempty', 'nonnan', 'real', 'finite'} ...
            );
        
        self.FftSize = fftSize;
    end
end


end


% End of file: AbstractFrequencySignal.m

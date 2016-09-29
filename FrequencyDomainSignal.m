classdef FrequencyDomainSignal < AbstractSignal
%FREQUENCYDOMAINSIGNAL <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% FrequencyDomainSignal Properties:
%	propA - <description>
%	propB - <description>
%
% FrequencyDomainSignal Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  29-Sep-2016 18:14:10
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (Access = protected)
    TimeDomainSignal;
end

properties (Access = protected, Dependent)
    FrequencyVector;
    Window;
    WindowedSignal;
end

properties
    FftSize = 512;
    WindowFunction = @(x) ones(x, 1);
    
    NumSamples;
    Duration;
    
    NumChannels;
end



methods
    function [self] = FrequencyDomainSignal(signal, sampleRate)
        if ~nargin
            return;
        end
        narginchk(1, 2)

        switch class(signal)
            case 'TimeDomainSignal'
                % do nothing
            case 'double'
                signal = TimeDomainSignal(signal, sampleRate);
            otherwise
                error('Signal class not recognized!');
        end 
        
        self.TimeDomainSignal = signal.Signal;
        self.SampleRate  = signal.SampleRate;
        
        self.computeFreqSignal();
    end
    
    function [ha] = plot(self)
        ha = axes;
        plot(...
            ha, ...
            self.FrequencyVector, ...
            20*log10(max(abs(self.Signal), eps)) ...
            );
        grid on;
        
        title('Spectrum of the Frequency Domain Signal');
        xlabel('Frequency in Hz');
        ylabel('Magnitude in dB');
        
        if self.NumChannels > 1
            legendText = arrayfun(...
                @(x) sprintf('Channel %d', x), ...
                1:self.NumChannels, ...
                'uni', false ...
                );
            legend(ha, legendText, 'location', 'best')
        end
    end
    
    function [val] = get.WindowedSignal(self)
        val = bsxfun(@times, self.TimeDomainSignal, self.Window);
    end
    
    function [val] = get.FrequencyVector(self)
        val = linspace(0, self.SampleRate/2, self.FftSize/2+1).';
    end
    
    function [val] = get.Window(self)
        val = self.WindowFunction(self.NumSamples);
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
    
    
    
    function [] = set.WindowFunction(self, windowFunction)
        validateattributes(windowFunction, ...
            {'function_handle'}, ...
            {'nonempty'} ...
            );
        
        self.WindowFunction = windowFunction;
        self.computeFreqSignal()
    end
    
    function [] = set.FftSize(self, fftSize)
        validateattributes(fftSize, ...
            {'numeric'}, ...
            {'scalar', 'positive', 'even', ...
             'nonempty', 'nonnan', 'real', 'finite'} ...
            );
        
        self.FftSize = fftSize;
        self.computeFreqSignal()
    end
end

methods (Access = protected)
    function [] = computeFreqSignal(self)
        freqSignal  = fft(self.WindowedSignal, self.FftSize);
        self.Signal = freqSignal(1:end/2+1, :);
    end
end


end




% End of file: FrequencyDomainSignal.m

classdef FrequencyDomain < Signal.AbstractClasses.AbstractFrequencySignal
%FREQUENCYDOMAIN <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% FrequencyDomain Properties:
%	propA - <description>
%	propB - <description>
%
% FrequencyDomain Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  29-Sep-2016 18:14:10
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (Access = public)
    FftSize = 512;
    WindowFunction = @(x) ones(x, 1);
end

properties (Access = protected, Dependent);
    Window;
end


methods
    function [self] = FrequencyDomain(varargin)
        self@Signal.AbstractClasses.AbstractFrequencySignal(varargin{:});
    end
    
    function [] = compute(self)
        freqSignal  = fft(self.WindowedSignal, self.FftSize);
        self.Signal = freqSignal(1:end/2+1, :);
    end
    
    function [ha] = plot(self)
        self.compute();
        
        ha = axes;
        plot(...
            ha, ...
            self.FrequencyVector, ...
            20*log10(max(abs(self.Signal), eps)) ...
            );
        grid on;
        xlim([self.FrequencyVector(1), self.FrequencyVector(end)]);
        
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
    
    
    function [val] = get.Window(self)
        val = self.WindowFunction(self.NumSamples);
    end
    
    function [] = set.WindowFunction(self, windowFunction)
        validateattributes(windowFunction, ...
            {'function_handle'}, ...
            {'nonempty'} ...
            );
        
        self.WindowFunction = windowFunction;
        self.compute();
    end
    
    function [] = set.FftSize(self, fftSize)
        validateattributes(fftSize, ...
            {'numeric'}, ...
            {'scalar', 'positive', 'even', ...
            'nonempty', 'nonnan', 'real', 'finite'} ...
            );
        
        self.FftSize = fftSize;
        self.compute();
    end
end



methods (Access = protected)
    function [yesNo] = AmIReady(self) %#ok<MANU>
        yesNo = true;
    end
end


end




% End of file: FrequencyDomain.m

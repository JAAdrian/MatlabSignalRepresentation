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
% Author :  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date   :  29-Sep-2016 18:14:10
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (SetAccess = protected, GetAccess = public)
    NumSamples;
    Duration;
    
    NumChannels;
end

properties (Access = public)
    FftSize = 512;
    WindowFunction = @(x) ones(x, 1);
end

properties (Access = protected, Dependent);
    Window;
end


methods
    function [self] = FrequencyDomain(varargin)
        if ~nargin
            varargin = {};
        end
        self@Signal.AbstractClasses.AbstractFrequencySignal(varargin{:});
        
        if nargin
            switch class(varargin{1})
                case 'Signal.TimeDomain'
                    objTime = varargin{1};
                    
                    self.time2freq(objTime);
                case 'Signal.FrequencyDomain'
                    self = varargin{1};
                case 'Signal.STFT'
                    error('Not yet implemented');
                case 'Signal.PSD'
                    error('Not yet implemented');
                case 'double'
                    self.Signal = varargin{1};
                    self.SampleRate = varargin{2};
                    
                    [self.NumSamples, self.NumChannels] = size(self.Signal);
                    
                    self.FftSize = (self.NumSamples - 1) * 2;
                    self.Duration = self.FftSize / self.SampleRate;
                otherwise
                    error('Signal class not recognized!');
            end
        end
    end
    
    function [ha] = plot(self)
        ha = axes;
        yyaxis left;
        
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
        
        yyaxis right;
        plot(...
            self.FrequencyVector, ...
            unwrap(angle(self.Signal)) / pi * 180 ...
            );
        xlabel('Frequency in Hz');
        ylabel('Unwrapped Phase in degree');
        
        if self.NumChannels > 1
            legendText = arrayfun(...
                @(x) sprintf('Channel %d', x), ...
                1:self.NumChannels, ...
                'uni', false ...
                );
            legend(ha, legendText, 'location', 'best')
        end
    end
    
    function [] = sound(self)
        objTime = Signal.TimeDomain(self);
        objTime.sound();
    end
    
    function [] = soundsc(self)
        objTime = Signal.TimeDomain(self);
        objTime.soundsc();
    end
    
    function [val] = get.Window(self)
        val = self.WindowFunction(self.NumSamples);
    end
    
    function [] = set.WindowFunction(self, windowFunction)
        validateattributes(windowFunction, ...
            {'function_handle'}, ...
            {'nonempty'} ...
            );
        
        objTime = Signal.TimeDomain(self);
        
        self.WindowFunction = windowFunction;
        self.time2freq(objTime);
    end
    
    function [] = set.FftSize(self, fftSize)
        validateattributes(fftSize, ...
            {'numeric'}, ...
            {'scalar', 'positive', 'even', ...
            'nonempty', 'nonnan', 'real', 'finite'} ...
            );
        
        objTime = Signal.TimeDomain(self);
        
        self.FftSize = fftSize;
        self.time2freq(objTime);
    end
end



methods (Access = protected)
    function [yesNo] = AmIReady(self)
        yesNo = ...
            ~isempty(self.FftSize) && ...
            ~isempty(self.WindowFunction);
    end
    
    function [] = time2freq(self, objTime)
        self.SampleRate = objTime.SampleRate;
        
        self.NumSamples  = objTime.NumSamples;
        self.Duration    = objTime.Duration;
        self.NumChannels = objTime.NumChannels;
        
        self.Signal = ...
            fft(diag(sparse(self.Window)) * objTime.Signal, self.FftSize, 1);
        
        self.Signal = self.Signal(1:end/2+1, :);
    end
end


end




% End of file: FrequencyDomain.m

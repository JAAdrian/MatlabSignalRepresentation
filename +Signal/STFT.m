classdef STFT < ...
        Signal.AbstractClasses.AbstractFrequencySignal & ...
        Signal.AbstractClasses.AbstractBlockedSignal
%STFT <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% STFT Properties:
%	propA - <description>
%	propB - <description>
%
% STFT Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  29-Sep-2016 21:03:33
%

% History:  v0.1   initial version, 29-Sep-2016 (JA)
%


properties (SetAccess = protected, GetAccess = public)
    NumSamples;
    Duration;
    
    NumChannels;
end

properties (Access = protected, Dependent)
    Window;
    PowerWeightingWindow;
end

properties (Access = protected)
    TimeVector;
end

properties (Access = public)
    FftSize = 512;;
    WindowFunction = @(x) hann(x, 'periodic');
end



methods
    function [self] = STFT(varargin)
        self@Signal.AbstractClasses.AbstractFrequencySignal(varargin{:});
        self@Signal.AbstractClasses.AbstractBlockedSignal(varargin{:});
        
        switch class(varargin{1})
            case 'Signal.TimeDomain'
                objTime = varargin{1};
                
                self.time2STFT(objTime);
            case 'Signal.FrequencyDomain'
                error('Not yet implemented');
            case 'Signal.STFT'
                error('Not yet implemented');
            case 'Signal.PSD'
                error('Not yet implemented');
            case 'double'
                self.Signal = varargin{1};
                self.SampleRate = varargin{2};
                
                [self.NumSamples, self.NumBlocks] = size(self.Signal);
                
                self.FftSize = (self.NumSamples - 1) * 2;
                self.Duration = self.FftSize / self.SampleRate;
            otherwise
                error('Signal class not recognized!');
        end
    end
    
    function [ha] = plot(self)
        ha = axes;
        
        PSD = abs(self.Signal).^2;
        PSD = (diag(sparse(self.PowerWeightingWindow)) * PSD) / ...
            (self.SampleRate * norm(self.Window)^2);
        
        imagesc(...
            ha, ...
            self.TimeVector, ...
            self.FrequencyVector, ...
            10*log10(max(PSD, eps^2)) ...
            );
        axis xy;
        hc = colorbar();
        hc.Label.String = 'PSD in dB re. 1^2/Hz';
        
        title('Spectrogram of the Signal');
        xlabel('Time in s');
        ylabel('Frequency in Hz');
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
        val = self.WindowFunction(self.BlockSizeSamples);
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
    
    
    function [val] = get.PowerWeightingWindow(self)
        val = 2 * ones(self.FftSize/2+1, 1);
        val([1, end]) = 1;
    end
end


methods (Access = protected)
    function [yesNo] = AmIReady(self)
        yesNo = ...
            ~isempty(self.Overlap) && ...
            ~isempty(self.BlockSize);
    end
    
    function [] = time2STFT(self, objTime)
        self.SampleRate = objTime.SampleRate;
        
        self.NumSamples  = objTime.NumSamples;
        self.Duration    = objTime.Duration;
        self.NumChannels = objTime.NumChannels;
        
        idxColumns = (0 : self.NumBlocks-1) * self.HopSize;
        idxRows    = (1 : self.BlockSizeSamples).';
        
        % pad with zeros
        timeDomainSignal = [...
            objTime.Signal; ...
            zeros(self.HopSize - self.RemainingSamples, 1) ...
            ];
        
        idxBlockedSignal = ...
            idxRows(:, ones(1, self.NumBlocks)) + ...
            idxColumns(ones(self.BlockSizeSamples, 1), :);
        blockedSignal = timeDomainSignal(idxBlockedSignal);
        
        spectrogramData = ...
            fft(diag(sparse(self.Window)) * blockedSignal, self.FftSize, 1);
        
        self.Signal     = spectrogramData(1:end/2+1, :);
        self.TimeVector = ...
            (idxColumns + self.BlockSizeSamples/2).' / self.SampleRate;
    end
end







end



% End of file: STFT.m

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

properties (Access = protected, Transient)
    TimeDomainObject;
end

properties (Access = public)
    FftSize = 512;
    WindowFunction = @(x) hann(x, 'periodic');
end



methods
    function [self] = STFT(varargin)
        if ~nargin
            varargin = {};
        end
        self@Signal.AbstractClasses.AbstractFrequencySignal(varargin{:});
        self@Signal.AbstractClasses.AbstractBlockedSignal(varargin{:});
        
        if nargin
            switch class(varargin{1})
                case 'Signal.TimeDomain'
                    objTime = varargin{1};
                    
                    self.SampleRate = objTime.SampleRate;
                    
                    self.NumSamples  = objTime.NumSamples;
                    self.Duration    = objTime.Duration;
                    self.NumChannels = objTime.NumChannels;
                    
                    self.TimeDomainObject = objTime;
                case 'Signal.FrequencyDomain'
                    error('Not yet implemented');
                case 'Signal.STFT'
                    self = varargin{1};
                case 'Signal.PSD'
                    error(...
                        'SIGNAL:noValidTransform', ...
                        'A PSD cannot be transformed into an STFT!' ...
                        );
                case 'double'
                    self.Signal = varargin{1};
                    self.SampleRate = varargin{2};
                    
                    self.NumSamples = size(self.Signal, 1);
                    
                    self.FftSize = (self.NumSamples - 1) * 2;
                    self.Duration = self.FftSize / self.SampleRate;
                    
                    self.TimeDomainObject = Signal.TimeDomain(self);
                otherwise
                    error('Signal class not recognized!');
            end
        end
    end
    
    function [] = transform(self)
        idxColumns = (0 : self.NumBlocks-1) * self.HopSizeSamples;
        idxRows    = (1 : self.BlockSizeSamples).';
        
        % pad with zeros if necessary
        timeDomainSignal = [...
            self.TimeDomainObject.Signal; ...
            zeros(self.HopSizeSamples - self.RemainingSamples, 1) ...
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
    
    function [psd, frequencyVector] = computePSD(self)
        psd = mean(abs(self.Signal).^2, 2);
        
        psd = self.PowerWeightingWindow .* psd / ...
            (self.SampleRate * norm(self.Window)^2);
        
        frequencyVector = self.FrequencyVector;
    end
    
    function [ha] = plot(self, plotType)
        if nargin < 2 || isempty(plotType)
            plotType = 'magnitude';
        end
        plotType = validatestring(plotType, {'magnitude', 'phase'});
        
        self.transform();
        
        ha = axes;
        
        switch plotType
            case 'magnitude'
                psd = abs(self.Signal).^2;
                psd = (diag(sparse(self.PowerWeightingWindow)) * psd) / ...
                    (self.SampleRate * norm(self.Window)^2);
                
                imagesc(...
                    ha, ...
                    self.TimeVector, ...
                    self.FrequencyVector, ...
                    10*log10(max(psd, eps^2)) ...
                    );
                axis xy;
                hc = colorbar();
                hc.Label.String = 'PSD in dB re. 1^2/Hz';
                
                title('Spectrogram of the Signal');
                xlabel('Time in s');
                ylabel('Frequency in Hz');
            case 'phase'
                error('Not yet implemented');
        end
    end
    
    function [] = sound(self)
        if ~isempty(self.TimeDomainObject)
            player = audioplayer(self.TimeDomainObject.Signal, self.SampleRate);
            play(player);
        else
            objTime = Signal.TimeDomain(self);
            objTime.sound();
        end
    end
    
    function [] = soundsc(self)
        if ~isempty(self.TimeDomainObject)
            signalNorm = ...
                self.TimeDomainObject.Signal / ...
                max(abs(self.TimeDomainObject.Signal));
            
            player = audioplayer(signalNorm, self.SampleRate);
            play(player);
        else
            objTime = Signal.TimeDomain(self);
            objTime.soundsc();
        end
        
    end
    
    function [val] = get.Window(self)
        val = self.WindowFunction(self.BlockSizeSamples);
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
end

end


% End of file: STFT.m

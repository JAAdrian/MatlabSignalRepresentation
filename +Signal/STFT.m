classdef STFT < Signal.AbstractClasses.AbstractFrequencySignal
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


properties (Access = protected)
    TimeVector;
end

properties (Access = protected, Dependent)
    BlockSizeSamples;
    OverlapSamples;
    
    HopSize;
    NumBlocks;
    RemainingSamples;
    
    Window;
    PowerWeightingWindow;
end

properties (Access = public)
    FftSize = 512;
    WindowFunction = @(x) hann(x, 'periodic');
    
    BlockSize;
    Overlap;
end


methods
    function [self] = STFT(varargin)
        self@Signal.AbstractClasses.AbstractFrequencySignal(varargin{:});
    end
    
    function [] = compute(self)
        idxColumns = (0 : self.NumBlocks-1) * self.HopSize;
        idxRows    = (1 : self.BlockSizeSamples).';
        
        % pad with zeros
        signal = [...
            self.TimeDomainSignal; ...
            zeros(self.HopSize - self.RemainingSamples, 1) ...
            ];
        
        idxBlockedSignal = ...
            idxRows(:, ones(1, self.NumBlocks)) + ...
            idxColumns(ones(self.BlockSizeSamples, 1), :);
        blockedSignal = signal(idxBlockedSignal);
        
        spectrogramData = ...
            fft(diag(sparse(self.Window)) * blockedSignal, self.FftSize, 1);
        
        self.Signal     = spectrogramData(1:end/2+1, :);
        self.TimeVector = ...
            (idxColumns + self.BlockSizeSamples/2).' / self.SampleRate;
    end
    
    function [ha] = plot(self)
        self.compute();
        
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
    
    
    function [val] = get.BlockSizeSamples(self)
        val = round(self.BlockSize * self.SampleRate);
    end
    
    function [val] = get.OverlapSamples(self)
        val = round(self.BlockSizeSamples * self.Overlap);
    end
    
    function [val] = get.HopSize(self)
        val = self.BlockSizeSamples - self.OverlapSamples;
    end
    
    function [val] = get.NumBlocks(self)
        % pad the last block with zeros
        val = ceil((self.NumSamples - self.OverlapSamples) / self.HopSize);
    end
    
    function [val] = get.RemainingSamples(self)
        val = rem(self.NumSamples - self.OverlapSamples, self.HopSize);
    end
    
    function [val] = get.Window(self)
        val = self.WindowFunction(self.BlockSizeSamples);
    end
    
    function [val] = get.PowerWeightingWindow(self)
        val = 2 * ones(self.FftSize/2+1, 1);
        val([1, end]) = 1;
    end
    
    
    
    function [] = set.BlockSize(self, val)
        validateattributes(val, ...
            {'numeric'}, ...
            {'scalar', 'positive', 'nonempty', 'nonnan', 'finite', 'real'} ...
            );
        
        self.BlockSize = val;
        self.updateFftSize();
    end
    
    function [] = set.Overlap(self, val)
        validateattributes(val, ...
            {'numeric'}, ...
            {'scalar', 'nonnegative', '>=', 0, '<=', 1, ...
             'nonempty', 'nonnan', 'finite', 'real'} ...
            );
        
        self.Overlap = val;
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


methods (Access = protected)
    function [yesNo] = AmIReady(self)
        yesNo = ...
            ~isempty(self.Overlap) && ...
            ~isempty(self.BlockSize);
    end
    
    function [] = updateFftSize(self)
        self.FftSize = pow2(nextpow2(self.BlockSizeSamples));
    end
end







end



% End of file: STFT.m

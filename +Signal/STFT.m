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


properties (Access = protected)
    TimeVector;
end

properties (Access = protected, Dependent)
    PowerWeightingWindow;
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
    
    function [] = updateFftSize(self)
        self.FftSize = pow2(nextpow2(self.BlockSizeSamples));
    end
end







end



% End of file: STFT.m

classdef PSD < Signal.STFT
%PSD <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% PSD Properties:
%	propA - <description>
%	propB - <description>
%
% PSD Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  01-Oct-2016 19:48:16
%

% History:  v0.1   initial version, 01-Oct-2016 (JA)
%



methods
    function [self] = PSD(varargin)
        self@Signal.STFT(varargin{:});
    end
    
    function [] = compute(self)
        compute@Signal.STFT(self);
        
        PSD = abs(self.Signal).^2;
        PSD = sum(PSD, 2);
        
        PSD = (diag(sparse(self.PowerWeightingWindow)) * PSD) / ...
            (self.SampleRate * norm(self.Window)^2);
        
        self.Signal = PSD;
    end
    
    function [ha] = plot(self)
        self.compute();
        
        ha = axes;
        plot(...
            ha, ...
            self.FrequencyVector, ...
            10*log10(max(self.Signal, eps^2)) ...
            );
        grid on;
        xlim([self.FrequencyVector(1), self.FrequencyVector(end)]);
        
        title('Power Spectral Density (PSD) of the Signal');
        xlabel('Frequency in Hz');
        ylabel('Magnitude in dB re. 1^2/Hz');
    end
end


end





% End of file: PSD.m

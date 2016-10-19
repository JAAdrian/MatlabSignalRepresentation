classdef AbstractBlockedSignal < Signal.AbstractClasses.AbstractSignal
%ABSTRACTBLOCKEDSIGNAL <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% AbstractBlockedSignal Properties:
%	propA - <description>
%	propB - <description>
%
% AbstractBlockedSignal Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  15-Oct-2016 00:21:56
%

% History:  v0.1   initial version, 15-Oct-2016 (JA)
%


properties (SetAccess = protected, GetAccess = public, Dependent)
    HopSizeSamples;
    NumBlocks;
end

properties (Access = protected, Dependent)
    BlockSizeSamples;
    OverlapSamples;
    
    RemainingSamples;
end

properties (Access = public, Abstract)
    BlockSize;
    Overlap;
end



methods
    function [self] = AbstractBlockedSignal(varargin)
        self@Signal.AbstractClasses.AbstractSignal(varargin{:});
    end
    
    function [val] = get.BlockSizeSamples(self)
        val = round(self.BlockSize * self.SampleRate);
    end
    
    function [val] = get.OverlapSamples(self)
        val = round(self.BlockSizeSamples * self.Overlap);
    end
    
    function [val] = get.HopSizeSamples(self)
        val = self.BlockSizeSamples - self.OverlapSamples;
    end
    
    function [val] = get.NumBlocks(self)
        % pad the last block with zeros
        val = ceil((self.NumSamples - self.OverlapSamples) / self.HopSizeSamples);
    end
    
    function [val] = get.RemainingSamples(self)
        val = rem(self.NumSamples - self.OverlapSamples, self.HopSizeSamples);
    end
end


methods (Access = protected)
    function [out] = WOLA(self)
        
    end
end



end



% End of file: AbstractBlockedSignal.m

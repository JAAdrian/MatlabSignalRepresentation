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
    HopSize;
    NumBlocks;
end

properties (Access = protected, Dependent)
    BlockSizeSamples;
    OverlapSamples;
    
    RemainingSamples;
end

properties (Access = public)
    BlockSize = 32e-3;
    Overlap = 0.5;
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
    
    function [] = set.BlockSize(self, val)
        validateattributes(val, ...
            {'numeric'}, ...
            {'scalar', 'positive', 'nonempty', 'nonnan', 'finite', 'real'} ...
            );
        
        self.BlockSize = val;
    end
    
    function [] = set.Overlap(self, val)
        validateattributes(val, ...
            {'numeric'}, ...
            {'scalar', 'nonnegative', '>=', 0, '<=', 1, ...
             'nonempty', 'nonnan', 'finite', 'real'} ...
            );
        
        self.Overlap = val;
    end
end


methods (Access = protected)
    function [out] = WOLA(self)
        
    end
end



end



% End of file: AbstractBlockedSignal.m

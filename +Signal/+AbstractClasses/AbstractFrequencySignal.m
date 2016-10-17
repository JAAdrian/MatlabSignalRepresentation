classdef AbstractFrequencySignal < Signal.AbstractClasses.AbstractSignal
%ABSTRACTFREQUENCYSIGNAL <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% AbstractFrequencySignal Properties:
%	propA - <description>
%	propB - <description>
%
% AbstractFrequencySignal Methods:
%	doThis - <description>
%	doThat - <description>
%
% Author :  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date   :  17-Oct-2016 11:43:58
%

% History:  v0.1   initial version, 17-Oct-2016 (JA)
%


properties (Access = protected, Dependent)
    FrequencyVector;
end

properties (Access = protected, Abstract)
    Window;
end

properties (Access = public, Abstract)
    FftSize;
    WindowFunction;
end




methods
    function [self] = AbstractFrequencySignal(varargin)
        self@Signal.AbstractClasses.AbstractSignal(varargin{:});
    end
    
    function [val] = get.FrequencyVector(self)
        val = linspace(0, self.SampleRate/2, self.FftSize/2+1).';
    end
end

end



% End of file: AbstractFrequencySignal.m

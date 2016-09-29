% This file is used for the MATLAB unit test engine.
% Run it by calling `runtests representations_test`.
%
% Author:  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date  :  29-Sep-2016 17:46:00
%

clear;
close all;

%% Instantiate a Simple Time Domain Signal
data = load('handel');

obj = TimeDomainSignal(data.y, data.Fs);

figure;
obj.plot([2 5]);

%% Instantiate a Simple Frequency Domain Signal
objTime = TimeDomainSignal([1, -0.95].', 16e3);

objFreq = FrequencyDomainSignal(objTime);

figure;
objFreq.plot();

%% Instantiate Frequency Domain Signal from Signal Vector
objFreq = FrequencyDomainSignal(data.y, data.Fs);



% End of file: representations_test.m

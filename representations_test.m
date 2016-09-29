% This file is used for the MATLAB unit test engine.
% Run it by calling `runtests representations_test`.
%
% Author:  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date  :  29-Sep-2016 17:46:00
%

clear;
close all;

%% Instantiate a Simple Time Domain Signal
[signal, fs] = audioread('speech.wav');

obj = Signal.TimeDomainSignal(signal, fs);

figure;
obj.plot([2 5]);

%% Instantiate a Simple Frequency Domain Signal
objTime = Signal.TimeDomainSignal([1, -0.95].', 16e3);
objFreq = Signal.FrequencyDomainSignal(objTime);

figure;
objFreq.plot();

%% Instantiate Frequency Domain Signal from Signal Vector
objFreq = Signal.FrequencyDomainSignal(signal, fs);

%% Instantiate an STFT object
objTime = Signal.TimeDomainSignal(signal, fs);

objSTFT = Signal.STFT(objTime);
objSTFT.BlockSize = 32e-3;
objSTFT.Overlap   = 0.5;

objSTFT.plot();


% End of file: representations_test.m

% This file is used for the MATLAB unit test engine.
% Run it by calling `runtests representations_test`.
%
% Author:  J.-A. Adrian (JA) <jens-alrik.adrian AT jade-hs.de>
% Date  :  29-Sep-2016 17:46:00
%

clear;
close all;

[signal, fs] = audioread('speech.wav');

%% Instantiate a Simple Time Domain Signal
obj = Signal.TimeDomain(signal, fs);

figure;
obj.plot();

%% Instantiate a Simple Frequency Domain Signal
objTime = Signal.TimeDomain([1, -0.95].', 16e3);
objFreq = Signal.FrequencyDomain(objTime);

figure;
objFreq.plot();

%% Instantiate Frequency Domain Signal from Signal Vector
objFreq = Signal.FrequencyDomain(signal, fs);

figure;
objFreq.plot();

%% Instantiate an STFT object
objTime = Signal.TimeDomain(signal, fs);

objSTFT = Signal.STFT(objTime);
objSTFT.BlockSize = 32e-3;
objSTFT.Overlap   = 0.5;

figure;
objSTFT.plot();

%% Instantiate a PSD object
objTime = Signal.TimeDomain(signal, fs);

objPSD = Signal.PSD(objTime);
objPSD.BlockSize = 32e-3;
objPSD.Overlap   = 0.5;

figure;
objPSD.plot();





% End of file: representations_test.m

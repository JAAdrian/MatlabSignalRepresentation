% This file is used for the MATLAB unit test engine.
% Run it by calling `runtests representations_test`.
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  29-Sep-2016 17:46:00
%

clear;
close all;

[signal, sampleRate] = audioread('speech.wav');

%% Instantiate a Simple Time Domain Signal
obj = Signal.TimeDomain(signal, sampleRate);

figure;
obj.plot();

%% Instantiate a Simple Frequency Domain Signal
objTime = Signal.TimeDomain([[1, -0.95].', [1, 0.95].'], 16e3);
objFreq = Signal.FrequencyDomain(objTime);
objFreq.FftSize = 2048;

figure;
objFreq.plot();

%% Instantiate Frequency Domain Signal from Signal Vector
sampleRate = 16e3;

slope = 256;
omega = linspace(0, pi, 257).';
phase = -slope * omega;

freqSignal = ones(257, 1) .* exp(1j * phase);
freqSignal([1, end]) = abs(freqSignal([1, end]));
freqSignal(150:end) = 0;

objFreq = Signal.FrequencyDomain(freqSignal, sampleRate);

figure;
objFreq.plot();

%% Go From Frequency to Time Domain
sampleRate = 16e3;

slope = 256;
omega = linspace(0, pi, 257).';
phase = -slope * omega;

freqSignal = ones(257, 1) .* exp(1j * phase);
freqSignal([1, end]) = abs(freqSignal([1, end]));
freqSignal(25:end) = 0;

objFreq = Signal.FrequencyDomain(freqSignal, sampleRate);
objTime = Signal.TimeDomain(objFreq);

figure;
objTime.plot();

%% Instantiate an STFT object
objTime = Signal.TimeDomain(signal, sampleRate);

objSTFT = Signal.STFT(objTime);

% not yet working
objSTFT.BlockSize = 32e-3;
objSTFT.Overlap   = 0.9;

figure;
objSTFT.plot();

%% Instantiate an STFT object and plot a PSD
objTime = Signal.TimeDomain(signal, sampleRate);

objSTFT = Signal.STFT(objTime);
objSTFT.BlockSize = 32e-3;
objSTFT.Overlap   = 0.5;

figure;
objSTFT.plotPSD();

psd = objSTFT.computePSD();
ir  = Signal.TimeDomain.psd2Time(psd, 'minimum');

figure;
stem(ir)



% End of file: representations_test.m

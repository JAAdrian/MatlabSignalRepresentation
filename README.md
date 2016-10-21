# MatlabSignalRepresentation
A number of MATLAB classes for common digital signal represenations.

This project aims at providing a set of classes to conveniently get from one digital signal domain to another. In detail, the classes are `TimeDomain`, `FrequencyDomain` and `STFT` for the short-time Fourier Transform (STFT) which also handles the power spectral density (PSD) estimate.

**Scenario**  
Consider having a time domain signal whose waveform you first want to analyze and then transform into frequency domain. You also want to listen to the signal. Vice versa, you created or received a frequency domain signal and want to plot the spectrum and/or get back to time domain without a lot of setup. The same scenario applies to the STFT class with the addition that you can also compute and plot the PSD estimate since it is based on a blocked signal. A time domain impulse response can be retrieved by a static method of the `TimeDomain` class.

## Installation

Make sure that the folder *containing* the `+Signal` package folder is visible by MATLAB (e.g listed in the MATLAB path).

Tested with MATLAB R2016a and R2016b.

## Usage

Let's see some examples of the classes and how to use them.

#### Time Domain Objects

As a simple start, consider having a time domain signal at hand which we want to encapsulate in a time domain object. This can easily achieved by the following:

```matlab
% grab an exsample signal
data = load('handel');

signal = data.y;
sampleRate = data.Fs;

obj = Signal.TimeDomain(signal, sampleRate)
```

This results in the following object:

```matlab
>> obj

obj =

  TimeDomain with properties:

     NumSamples: 73113
       Duration: 8.9249
    NumChannels: 1
         Signal: [73113x1 double]
     SampleRate: 8192
```

```matlab
>> methods(obj)

Methods for class Signal.TimeDomain:

TimeDomain  plot        resample    sound       soundsc     

Static methods:

psd2Time    

Methods of Signal.TimeDomain inherited from handle.
```


## License

The code is licensed under BSD 3-Clause license.

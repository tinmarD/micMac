function [SC] = mm_morletscalogram(data, srate, pfreq, wavecycles)
% [SC] = MM_MORLETSCALOGRAM (data, srate, min_pfreq, max_pfreq, n_pfreqs, min_cycle, max_cycle)
%   Get the wavelet scalogram using Complex Morlet Wavelets ranging from
%   min_pfreq to max_pfreq, with cycles ranging from min_cycle to
%   max_cycle. Both frequencies and cycles are spaced equally on a log10
%   scale
%
% Author : Martin Deudon (April 2018)
%
% INPUTS 
%   - data          : 1D data array 
%   - srate         : Sampling frequency of the data (Hz)
%   - pfreq 
%   - wavecycles
%
% OUTPUTS
%   - SC            : Wavelet Scalogram  
% 

% pfreq       = logspace(log10(min_pfreq),log10(max_pfreq),n_pfreqs);
% wavecycles  = logspace(log10(min_cycle),log10(max_cycle),n_pfreqs);
n_pnts      = length(data);
time        = -2:1/srate:2;
n_wave      = length(time);
n_conv      = n_pnts + n_wave - 1;
dataX       = fft(data, n_conv);
n_halfwave  = (length(time)-1)/2;
SC          = zeros(length(pfreq), n_pnts);


for i = 1:length(pfreq)
    % create wavelet and get its FFT
    s = wavecycles(i)/(2*pi*pfreq(i));
    wavelet  = exp(2*1i*pi*pfreq(i).*time) .*  exp((-time.^2) ./ (2*s^2));
    waveletX = fft(wavelet,n_conv);
    waveletX = waveletX ./ max(waveletX);
    % run convolution
    conv_tmp = ifft(waveletX.*dataX,n_conv);
    SC(i,:)  = conv_tmp(n_halfwave+1:end-n_halfwave);
end

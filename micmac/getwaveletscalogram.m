function [ SC, pfreqs, scales, phase] = getwaveletscalogram(x, Fs, wname, pf_min, pf_max, pf_step, log_scale, normMethod, cycle_min, cycle_max, return_phase)
% [ SC, pseudofreq, scales] = getWaveletScalogram 
%           (x, Fs, wname, pf_min, pf_max, pf_step, log_scale, normMethod cycle_min, cycle_max)
if nargin==10
    return_phase = 0;
end
phase = [];

if log_scale
    n_freqs     = pf_step;
    pfreqs      = logspace(log10(pf_min),log10(pf_max),n_freqs);
else
    pfreqs      = pf_min:pf_step:pf_max;
    n_freqs     = length(pfreqs);
end

if strcmp(wname ,'cmor-var')
    if log_scale
        wav_cycles  = logspace(log10(cycle_min),log10(cycle_max),n_freqs);
    else
        wav_cycles  = linspace(cycle_min, cycle_max, n_freqs);
    end
    scalogram       = mm_morletscalogram(x, Fs, pfreqs, wav_cycles);
    if return_phase
        phase = angle(scalogram);
    end
    coeffs          = abs(scalogram);
    S               = coeffs.^2;
    scales          = pfreqs;
elseif strcmp(wname,'morse')
    beta            = 6;
    gamma           = 20;
%     wave_fc         = 0.3;
    wave_fc         = ((beta/gamma).^(1/gamma))/(2*pi);
    scales          = wave_fc*Fs./pfreqs;
    nk              = 1;
    morseScalogram  = zeros(length(pfreqs),length(x),nk);
    for k=0:nk-1
        morseScalogram(:,:,k+1)=wscal55b(x,scales,beta,gamma,k,0.5);
    end
    S               = mean(abs(morseScalogram).^2,3);
    coeffs          = sqrt(S);
else
    wave_fc         = centfrq (wname);
    scales          = wave_fc*Fs./pfreqs;
    [coeffs]        = cwt(x,scales,wname);
    S               = abs(coeffs.*coeffs);
end


%== Normalization
if strcmpi(normMethod,'Log')
    SC = abs(S);
    SC = log10(SC+0.1);
elseif strcmpi(normMethod,'Log-L²')
    %- Normalize CWT coeffs in L² (weighting function is 1/a and not 1/sqrt(a))
    coeffNorm   = coeffs./repmat(sqrt(scales(:)),1,size(coeffs,2));
    SC          = abs(coeffNorm.*coeffNorm);
    SC          = log10(SC+0.1);
elseif strcmpi(normMethod,'Z-score')
    % Compute Z-score across each pseudo-frequency
    coeffsMean 	= mean(coeffs,2);
    coeffsStd 	= std(coeffs,0,2);
    coeffsNorm  = (coeffs-repmat(coeffsMean,1,size(coeffs,2)))./repmat(coeffsStd,1,size(coeffs,2));
    SC          = abs(coeffsNorm.*coeffsNorm);
elseif strcmpi(normMethod,'Z-H0')
    SC      = getwhitenedscalogram(coeffs,scales);    
elseif strcmpi(normMethod,'None')
    SC = S;
else
    warning('Wrong argument for normalization method');
    SC = S;
end        

% Normalize by total energy over all pseudo-freq
% SC              = 100*S./sum(S(:)); % Useless if used before imagesc

end

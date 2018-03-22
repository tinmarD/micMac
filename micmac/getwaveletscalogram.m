function [ SC, pseudofreq, scales] = getwaveletscalogram(x, Fs, wname, pseudo_f_min, pseudo_f_max, pseudo_f_step, normMethod)
% [ SC, pseudo_freq, scales] = getWaveletScalogram 
%           (x, Fs, wname, pseudo_f_min, pseufo_f_max, pseudo_f_step, normMethod))

pseudofreq          = pseudo_f_min:pseudo_f_step:pseudo_f_max;
if strcmp(wname,'morse')
    beta            = 6;
    gamma           = 20;
%     wave_fc         = 0.3;
    wave_fc         = ((beta/gamma).^(1/gamma))/(2*pi);
    scales          = wave_fc*Fs./pseudofreq;
    nk              = 1;
    morseScalogram  = zeros(length(pseudofreq),length(x),nk);
    for k=0:nk-1
        morseScalogram(:,:,k+1)=wscal55b(x,scales,beta,gamma,k,0.5);
    end
    S               = mean(abs(morseScalogram).^2,3);
    coeffs          = sqrt(S);
else
    wave_fc         = centfrq (wname);
    scales          = wave_fc*Fs./pseudofreq;
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

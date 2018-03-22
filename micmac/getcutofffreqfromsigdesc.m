function [ fLow, fHigh ] = getcutofffreqfromsigdesc(sigdesc)
% [fLow, fHigh] = GETCUTOFFFREQFROMSIGDESC(sigdesc)
% Returns the low and high cutoff frequencies for a filtered signal
% from the signal's description
%
% INPUTS : 
%   - sigdesc       : Signal description
% 
% OUTPUTS : 
%   - fLow        	: Low cutoff frequency (in Hz)
%   - fHigh         : High cutoff frequency (in Hz)

fLow    = '';
fHigh   = '';

if ~isempty(regexp(sigdesc,'<f<','once'))           % Bandpass filtered signal
    fLow = cell2mat(regexp(sigdesc,'\d+Hz<','match'));
    if ~isempty(fLow)
        fLow = cell2mat(regexp(fLow,'\d+','match'));
    end    
    fHigh = cell2mat(regexp(sigdesc,'f<\d+Hz','match'));
    if ~isempty(fHigh)
        fHigh = cell2mat(regexp(fHigh,'\d+','match'));
    end  
elseif ~isempty(regexp(sigdesc,'f>','once'))        % Highpass filtered signal
    fLow = cell2mat(regexp(sigdesc,'f>\d+','match'));
    if ~isempty(fLow)
        fLow = cell2mat(regexp(fLow,'\d+','match'));
    end        
elseif ~isempty(regexp(sigdesc,'f<\d+','once'))    	% Lowpass filtered signal
    fHigh = cell2mat(regexp(sigdesc,'f<\d+Hz','match'));
    if ~isempty(fHigh)
        fHigh = cell2mat(regexp(fHigh,'\d+','match'));
    end  
end
% else raw signal

end


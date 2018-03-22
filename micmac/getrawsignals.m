function [rawInd, rawDesc] = getrawsignals (ALLSIG)
%[rawInd, rawDesc] = GETRAWSIGNALS (ALLSIG)
% Return indices in the ALLSIG structure and descriptions of raw signals
% Function equivalent to getsignal
%
% INPUT: 
%   - ALLSIG
%
% OUTPUTS:
%   - rawInd            : Indices of the raw signal in ALLSIG [vector]
%   - rawDesc           : Description of all raw signal [cell]
%
% See also getsignal, getsigchildren

rawDesc = {};
rawInd  = [];

if isempty(ALLSIG)
    return;
end

nrawsig   	= sum(cat(1,ALLSIG.israw));
rawDesc     = cell(1,nrawsig);

rawInd      = nonzeros((cat(1,ALLSIG.israw)==1).*((1:length(ALLSIG)).'));
for i=1:length(rawInd)
    rawDesc {i} = ALLSIG(rawInd(i)).desc;
end

end


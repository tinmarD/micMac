function [childSigs, sigInd, childId] = getsigchildren (ALLSIG, parentId)
% [childSigs, sigInd, childId] = getsigchildren (ALLSIG, parentId)
%  Returns the children signals of a parent signal  .
%       -> Use getsignal rather than this function
%
% INPUTS :
%   - ALLSIG
%   - parentId          : ID of the parent signal (scalar)
%
% OUTPUTS:  
%   - childSigs         : Signal structures of children
%   - sigInd            : Indices of children signals [logical vector]
%   - childId           : IDs of children signals
%
% See also getsigfromdesc, getsignal, getrawsignals


sigInd = zeros(1,length(ALLSIG));
for i=1:length(ALLSIG)
    pid = ALLSIG(i).parent;
    while pid~=-1
        if pid==parentId; 
            sigInd(i) = 1; 
            break;
        end;
        [~,~,~,pid] = getsignal (ALLSIG, pid);
    end
end

childSigs   = ALLSIG(logical(sigInd));
childId     = cat(1,childSigs.id);

end


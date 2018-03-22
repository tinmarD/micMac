function [ Sig, sigpos ] = getsigfromid(ALLSIG, sigid)
% [sigpos, SIG] = getsigfromid(ALLSIG, sigid)
% Returns the signal position in the ALLSIG structure and the Signal
% structure
% 
% Equivalent to getsignal(ALLSIG,'sigid',id) 
% Faster but useful ?

sigpos  = nonzeros((cat(2,ALLSIG.id)==sigid).*(1:length(ALLSIG)));
Sig     = ALLSIG(sigpos);

end


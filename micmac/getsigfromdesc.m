function [ Sig, sigpos ] = getsigfromdesc(ALLSIG, sigdesc)
% [sigpos, SIG] = GETSIGFROMDESC (ALLSIG, sigid)
% Returns the signal position in the ALLSIG structure and the Signal
% structure

sigpos  = nonzeros(strcmp(  arrayfun(@(x)x.desc,ALLSIG,'UniformOutput',false),...
                            sigdesc).*(1:length(ALLSIG)));
Sig     = ALLSIG(sigpos);

end
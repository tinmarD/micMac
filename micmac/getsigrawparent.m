function [pSig, rawid] = getsigrawparent (ALLSIG, sigid)
% [pSig, pid] = getsigrawparent (ALLSIG, sigid)
% Return the Sig structure and id of the raw parent signal of sigid  

pSig    = [];
rawid   = [];

if isempty(ALLSIG) || isempty(sigid);
    return;
else
    rawid = zeros(1,length(sigid));
    for i=1:length(sigid)
        [pSig,~,rawid,pid,~,~,~,israw] = getsignal (ALLSIG, sigid(i));
        while ~israw
            [pSig,~,~,pid,~,~,~,israw] = getsignal (ALLSIG, pid);
            rawid = pSig.id;
        end
        pSig(i)  = pSig;
        rawid(i) = rawid;
    end
end

end


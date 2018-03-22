function res = areparentsig (ALLSIG, sigid1, sigid2)
% res = AREPARENTSIG (ALLSIG, sigid1, sigid2)
% Check if 2 signals identified by sigid1 and sigid2 have a commun 
% ancestor or not (and thus the same channels configuration)
%
% Returns 1 if true, 0 otherwise

ancestorSig1 = getsignal (ALLSIG, 'sigid', sigid1);
ancestorSig2 = getsignal (ALLSIG, 'sigid', sigid2);

ancestor1 = ancestorSig1.parent;
ancestor2 = ancestorSig2.parent;   
while ancestor1 ~= -1
    ancestorSig1 = getsignal  (ALLSIG, 'sigid', ancestor1);
    ancestor1    = ancestorSig1.parent;
end
while ancestor2 ~= -1
    ancestorSig2 = getsignal (ALLSIG, 'sigid', ancestor2);
    ancestor2    = ancestorSig2.parent;
end


if ancestorSig1.id==ancestorSig2.id
    res=1;
else    
    if strcmp([ancestorSig1.filepath,ancestorSig1.filename],[ancestorSig2.filepath,ancestorSig2.filename])
        res=1;
    else
        res=0;
    end
end

            

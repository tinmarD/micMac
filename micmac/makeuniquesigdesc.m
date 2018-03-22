function [sigdesc] = makeuniquesigdesc(ALLSIG, sigdesc)
% [sigdesc] = makeuniquesigdesc(ALLSIG, sigdesc)
inc=2;
while sum(strcmp(sigdesc,arrayfun(@(x)x.desc,ALLSIG,'uniformOutput',false)))~=0
    sigdesc = fastif(inc==2,[sigdesc,'-',num2str(inc)],...
            [sigdesc(1:end-length(num2str(inc-1))),num2str(inc)]);
    inc = inc+1;
end
end
function [chanselout] = getcorrchannels(VI, ALLWIN, ALLSIG, winnb, viewnb, chanselin)
% chansel = GETCORRCHANNELS(VI, ALLWIN, ALLSIG, winnb, viewnb)
% Get the corresponding channels between the first view and the the 
% view VIEWNB (each view having its own signal)
% Return the indices of the correponding channels
% chansel = GETCORRCHANNELS(..., viewnb, chanselin)
% Get the corresponding channels of chanselin (first view) between the first
% view and the the view VIEWNB (each view having its own signal)

%- First check if the window channel selection is synchronized with the
% main window
syncchansel = 0;
if winnb~=1 && sum(ALLWIN(1).syncchanselwin==winnb)~=0
    syncchansel = 1;
end

Win = ALLWIN(winnb);
if ~syncchansel && areparentsig (ALLSIG, Win.views(1).sigid,Win.views(viewnb).sigid)
	chanselout = Win.chansel;
    if nargin==6; chanselout=chanselin; end;
elseif syncchansel && areparentsig (ALLSIG, ALLWIN(1).views(1).sigid, Win.views(viewnb).sigid)
    chanselout = ALLWIN(1).chansel;
    if nargin==6; chanselout=chanselin; end;
else
    [~,rawid2]  = getsigrawparent   (ALLSIG, Win.views(viewnb).sigid);
    [~,sigpos2] = getsignal         (ALLSIG, 'sigid', rawid2);
    if syncchansel
        [~,rawid1]  = getsigrawparent   (ALLSIG, ALLWIN(1).views(1).sigid);
        Win = ALLWIN(1);
    else
        [~,rawid1]  = getsigrawparent   (ALLSIG, Win.views(1).sigid);
    end
    [~,sigpos1] = getsignal         (ALLSIG, 'sigid', rawid1);
    chancorr    = VI.chancorr{sigpos1,sigpos2};
    if isempty(chancorr)
        dispinfo ('No channel correspondency between the two signals');
        chanselout = [];
    else
        dispinfo ('');
        if nargin==5
            chanselout  = arrayfun(@(x,y)x:y,chancorr(Win.chansel,1),...
            	chancorr(Win.chansel,2),'UniformOutput',false);
%             chanselout  = unique([chanselout{:}]);
        elseif nargin==6
            chanselout  = arrayfun(@(x,y)x:y,unique(chancorr(chanselin,1)),...
            	unique(chancorr(chanselin,2)),'UniformOutput',false); 
        end
        chanselout  = nonzeros(unique(cat(2,chanselout{:})));
    end
end

chanselout = chanselout(:)';

end


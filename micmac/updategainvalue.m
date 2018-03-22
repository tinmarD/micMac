function [ALLWIN] = updategainvalue(ALLWIN)
%[ALLWIN] = UPDATEGAINVALUE (ALLWIN)
%   This function is called each time the window is resized. It allows to
%   update the value of the gain for views in 'Spaced Mode' so that the
%   scale (in uV/cm) remains constant after the resize. 

winnb = find(cat(1,ALLWIN.figh)==gcbf);
if isempty(ALLWIN(winnb).views) || ALLWIN(winnb).visumode==1
    return; 
else
    viewSelPos = find(strcmp({ALLWIN.views.domain},'t'));
    if isempty(viewSelPos); return; end;
    for i=1:length(viewSelPos)
        scale   = ALLWIN(winnb).views(viewSelPos(i)).scale;
        if isnan(scale); return; end;
        axHandle= ALLWIN(winnb).axlist(viewSelPos(i));
        ALLWIN(winnb).views(viewSelPos(i)).gain(2) = getgainfromampscale(scale,2);
    end
end



end


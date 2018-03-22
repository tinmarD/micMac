function [viewFocusedPos] = getfocusedviewpos(Win, axHandle)
%[viewFocusedPos] = GETFOCUSEDVIEWPOS(Win)
% Or    [...]     = GETFOCUSEDVIEWPOS(Win, axHandle)
%   Returns the focused view's position in the Win.views array

viewFocusedPos = [];

if isempty(Win.axlist); return; end;
if isempty(Win.views);  return; end;

if nargin==1
    axfocus = Win.axfocus;
else
    axfocus = axHandle;
end
if ~ismember(Win.axfocus,Win.axlist); return; end;

nViews = length(Win.views);

if Win.visumode == 1 % Stacked mode
    viewFocusedPos = find(Win.axlist == axfocus);
    viewFocusedPos = find(cumsum(strcmp('t',{Win.views.domain}))==viewFocusedPos);
    if isempty(viewFocusedPos); return; end;
    viewFocusedPos = viewFocusedPos(1);
elseif Win.visumode == 2 % Spaced mode
    axFocusPos          = find(Win.axlist == axfocus);
    viewFocusedPos      = rem(axFocusPos,nViews);
    if viewFocusedPos==0
        viewFocusedPos  = nViews;
    end
end


end


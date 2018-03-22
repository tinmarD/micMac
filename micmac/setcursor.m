function [VI, ALLWIN] = setcursor (VI, ALLWIN, ALLSIG, cursortype)
%[VI, ALLWIN] = SETCURSOR (VI, ALLWIN, ALLSIG, cursortype)
%   Function called when the user uses one of the cursor button is selected

% Delete all the previous graphical components
try delete(VI.cursor.hlastcursor); catch; end;
try delete(VI.cursor.hfirstcursor); catch; end;

% Remove mouse motion callback
set(gcbf,'WindowButtonMotionFcn','');

if VI.cursor.type == cursortype
    VI.cursor.type = 0;
else
    VI.cursor.type = cursortype;
end


winnb = find(cat(1,ALLWIN.figh)==gcbf);
if VI.cursor.type ~= 1
    for axh=ALLWIN(winnb).axlist
        set (axh,'ButtonDownFcn','');
    end    
end

if cursortype == 0
    VI.cursor.haxis = [];
    VI.cursor.inc   = 0;
end

% redraw 
[ALLWIN] = redrawwin(VI, ALLWIN, ALLSIG);

end


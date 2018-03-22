function [VI, ALLWIN, ALLSIG] = renamesignaldesc (VI, ALLWIN, ALLSIG, ...
    sigFilename, sigFilepath, newSigDesc)
% [VI, ALLWIN, ALLSIG] = RENAMESIGNALDESC (VI, ALLWIN, ALLSIG, ...
%     sigFilename, sigFilepath, newSigDesc)
% Rename a raw signal (from pop_signalproperties)
% View name is formatted : '[View.id] [Sig.desc]-[View.domain]' 
% 
% INPUTS : 
%   - VI, ALLWIN, ALLSIG
%   - sigFilename           : Signal filename
%   - sigFilepath           : Signal filepath
%
% OUTPUTS : 
%   - VI, ALLWIN, ALLSIG


[Sig, sigsel]   = getsignal (ALLSIG, 'filename', sigFilename, 'filepath', sigFilepath, 'israw', 1);
oldsigdesc      = Sig.desc;

%- If signal description has not changed, return
if strcmp(newSigDesc,oldsigdesc); return; end;

%- Check that the new signal description is not already used
if ~isempty( getsignal(ALLSIG, 'desc', newSigDesc) )
    msgbox ('Signal''s name must be unique');
    set (gcbo,'String',oldsigdesc,'Style','text');
    return;
end

%- Rename the labels in the View menu which use this signal
for i=1:length(ALLWIN)
    %- Find the main window View menu
    viewmenu    = findobj(ALLWIN(1).figh, 'type', 'uimenu', 'Label', 'Views');
    viewmenuobj = findobj(viewmenu, 'type', 'uimenu');
    viewlabels  = get(viewmenuobj,'label');
    viewmatch   = regexp(viewlabels,[' ',oldsigdesc],'match');
    viewmatchsel= cellfun(@(x)~isempty(x),viewmatch);
    viewid      = cellfun(@(x)str2double(x(1)),viewlabels);
    viewparents = zeros(length(viewmenuobj),1);
    %- For each view, verify that the view's signal is parent with our
    %signal of interest
    for j=1:length(viewid)
        if isnan(viewid(j)); continue; end;
        View = getview(ALLWIN, viewid(j));
        if areparentsig (ALLSIG, View.sigid, Sig.id);
            viewparents (j) = 1;
        end
    end
    viewmenuobjsel = viewmenuobj(viewmatchsel&viewparents);
    for j=1:length(viewmenuobjsel)
        oldlabel = get(viewmenuobjsel(j),'Label');
        set (viewmenuobjsel(j),'Label',regexprep(oldlabel,[' ',oldsigdesc],[' ',newSigDesc]));
    end
end
    
%- Rename the labels in the Signals menu in the main window
sigmenu     = findobj(ALLWIN(1).figh, 'type', 'uimenu', 'Label', 'Signals');
sigmenuobj  = findobj(sigmenu, 'type', 'uimenu');
siglabels   = get(sigmenuobj,'label');
sigmatch    = regexp(siglabels,['^',oldsigdesc],'match');
sigmatchsel = cellfun(@(x)~isempty(x),sigmatch);
sigmenuobjsel = sigmenuobj(sigmatchsel);
for j=1:length(sigmenuobjsel)
    oldlabel = get(sigmenuobjsel(j),'Label');
    set (sigmenuobjsel(j),'Label',regexprep(oldlabel,oldsigdesc,newSigDesc));    
end

%- Rename the event field 
for i=1:length(VI.eventall)
    if areparentsig(ALLSIG, VI.eventall(i).sigid, Sig.id)
        VI.eventall(i).sigdesc = regexprep(VI.eventall(i).sigdesc,oldsigdesc,newSigDesc);
    end
end
for i=1:length(VI.eventsel)
    if areparentsig(ALLSIG, VI.eventall(i).sigid, Sig.id)
        VI.eventsel(i).sigdesc = regexprep(VI.eventall(i).sigdesc,oldsigdesc,newSigDesc);
    end
end     
[VI] = updateeventsel (VI, 1);

%- Change the signal desc in the ALLSIG structure 
% in the raw sig
ALLSIG(sigsel).desc = newSigDesc;
% and in the children signals
[~, sigchildpos] = getsigchildren (ALLSIG, Sig.id);
sigchildpos = find(sigchildpos==1);
for i=1:length(sigchildpos)
	ALLSIG(sigchildpos(i)).desc = regexprep(ALLSIG(sigchildpos(i)).desc,oldsigdesc,newSigDesc);
end
    
end
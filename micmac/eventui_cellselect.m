function [] = eventui_cellselect(~, cbdata)

if ~isempty(cbdata.Indices)
    evalin ('base',['[VI, ALLWIN, ALLSIG] = '...
        'navigateevent (VI, ALLWIN, ALLSIG, ''goto'', ',num2str(cbdata.Indices(1)),');']);
end

end
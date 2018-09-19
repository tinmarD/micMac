function [VI,eventsel] = updateeventsel (VI, externalcall, selectall)
% [VI,eventsel] = UPDATEEVENTSEL (VI, externalcall, selectall)
%   Update the event selection when user modify the selection parameters on
%   the event gui (pop_seeevents) or from another function
%
% See also pop_seeevents, orderevents, navigateevent

eventwin = fastif (nargin==1,gcbf,findobj('tag','eventwindow'));
if isempty(eventwin); return; end;

typepop = findobj (eventwin,'tag','typepop');
sigpop  = findobj (eventwin,'tag','sigpop');
chanpop = findobj (eventwin,'tag','chanpop');
selall  = findobj (eventwin,'tag','selallcb');

%- Select all activated
if ~isempty(gcbo) && (gcbo==selall && get(selall,'value')) || nargin==3
    VI.eventsel = VI.eventall;
    %- reset selection panel
    set (typepop,'value',1);
    set (sigpop, 'value',1);
    set (chanpop,'value',1);
    set (findobj (gcbf,'tag','extypecb'), 'value',0);
    set (findobj (gcbf,'tag','exsigcb'),  'value',0);
    set (findobj (gcbf,'tag','exchancb'), 'value',0);
else
    % Get the selection criteria
    %-
    typestr = get (typepop,'string');
    sigstr  = get (sigpop,'string');
    chanstr = get (chanpop,'string');
    if ~isempty(typestr)       
        %-
        typesel     = typestr{get(typepop,'value')};
        sigdescsel  = sigstr{get(sigpop,'value')};
        channamesel = chanstr{get(chanpop,'value')};
        %- exclude ?
        typeex  = get (findobj (gcbf,'tag','extypecb'), 'value');
        sigex   = get (findobj (gcbf,'tag','exsigcb'), 'value');
        chanex  = get (findobj (gcbf,'tag','exchancb'), 'value');
        if typeex;  typesel     = setxor(typestr,typesel);      end; 
        if sigex;   sigdescsel  = setxor(sigstr,sigdescsel);    end; 
        if chanex;  channamesel = setxor(chanstr,channamesel);  end; 

        typesel     (strcmp(typesel,'All'),:)     = '';
        sigdescsel  (strcmp(sigdescsel,'All'),:)  = '';
        channamesel (strcmp(channamesel,'All'),:) = '';

        % Get the selected events
        [~,eventsel] = getevents (VI,'type',typesel,'sigdesc',sigdescsel,'channame',channamesel);

        VI.eventsel = VI.eventall(eventsel);

        %- Get the color of selected event
        changecolorpb       = findobj(gcbf,'tag','changecolorpb');
        if isempty(VI.eventsel)
            set(changecolorpb,'ForegroundColor',[0,0,0]);
        else
%             VI.eventpos = 1;
            eventColors         = reshape([VI.eventsel.color],3,length(VI.eventsel))';
            eventUniqueColors   = unique(eventColors,'rows');
            if size(eventUniqueColors,1)==1
                if ~isempty(changecolorpb)
                    set(changecolorpb,'ForegroundColor',eventUniqueColors);
                end
            else
                if ~isempty(changecolorpb)
                    set(changecolorpb,'ForegroundColor',[0,0,0]);
                end                   
            end
        end

        set (selall,'value',0);
    end

end

%- Repopulate the table
t = findobj (eventwin,'tag','eventtable');
eventdata   = VI.eventsel;
durationstr = arrayfun(@(x)sprintf('%.2f',x.duration),eventdata,'Uniformoutput',false);
tposstr     = arrayfun(@(x)sprintf('%.2f',x.tpos),eventdata,'Uniformoutput',false);
freqstr     = arrayfun(@(x)sprintf('%d',x.centerfreq),eventdata,'Uniformoutput',false);
if ~isempty(eventdata)
    eventposcell            = num2cell(1:length(eventdata));% mat2cell((1:nevent)',ones(nevent,1),1);
    [eventdata.eventpos]    = eventposcell{:};
    [eventdata.duration] 	= durationstr{:};
    [eventdata.tpos]        = tposstr{:};
    [eventdata.centerfreq]  = freqstr{:};
    nfields     = length(fieldnames(eventdata));
    eventdata   = orderfields(eventdata,[nfields,2:nfields-1,1]);
    eventdata   = squeeze(struct2cell(eventdata))';
    %- Remove channelind, sigid, rawparentid fields
    eventdata(:,[5,7,9,11])=[];

    set (t, 'data',eventdata);
    set (t, 'ColumnName', {'','Type','Time (s)','Duration (s)','Channel','Signal','Frequency'});
    set (t, 'ColumnWidth',{15,'auto','auto','auto','auto','auto','auto'});
    set (t, 'RowName', []);
    set (t, 'ColumnEditable', [false true false false false false false]);
    set (t, 'CellEditCallback', @eventui_celledit);
    set (t, 'CellSelectionCallback', @eventui_cellselect);

    etypes      = unique({VI.eventall.type});           etypes      = ['All';etypes(:)];
    esigdesc    = unique({VI.eventall.sigdesc});        esigdesc    = ['All';esigdesc(:)];
    echannames  = unique({VI.eventall.channelname});    echannames  = ['All';echannames(:)];

%         etypes      = unique(eventdata(:,2));   etypes      = ['All';etypes];
%         esigdesc    = unique(eventdata(:,6));   esigdesc    = ['All';esigdesc];
%         echannames  = unique(eventdata(:,5));   echannames  = ['All';echannames];

else
    set (t,'data',[]);
    set (findobj(eventwin,'tag','navigedit'), 'string', num2str(VI.eventpos));
    etypes      = {''};
    esigdesc    = {''};
    echannames  = {''};
end

%- Update the selection field values
set (findobj(eventwin,'tag','typepop'),'string',etypes);
set (findobj(eventwin,'tag','sigpop'),'string',esigdesc);
set (findobj(eventwin,'tag','chanpop'),'string',echannames);

%- Field selected must be within String range
set (findobj(eventwin,'tag','typepop'),'value',...
    min(get(findobj(eventwin,'tag','typepop'),'value'),length(etypes)));
set (findobj(eventwin,'tag','sigpop'),'value',...
    min(get(findobj(eventwin,'tag','sigpop'),'value'),length(esigdesc)));
set (findobj(eventwin,'tag','chanpop'),'value',...
    min(get(findobj(eventwin,'tag','chanpop'),'value'),length(echannames)));

%- Update the number of selected events
set (findobj(eventwin,'tag','noetext'),'string',num2str(length(VI.eventsel)));

%- Update the navigation 
set (findobj(eventwin,'tag','navigedit'),'string',num2str(VI.eventpos));
    
end

function [VI, ALLWIN, ALLSIG] = pop_rejectevents(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_REJECTEVENTS(VI, ALLWIN, ALLSIG)
%   Pop-up window to reject time-period defined by global events. Create a
%   new signal exluding (or including only) the events time.
%   Events should be global.
%   Only signals containing at least one event with the selected type are
%   shown in the sigal selection box



[~, ~, evtypes_glob] = getevents(VI, 'chanind', -1);
evtypes_glob = unique(evtypes_glob);
if isempty(evtypes_glob)
    msgbox('Global events should be defined before rejecting events');
    return;
end
sigdesc = unique({ALLSIG.desc});
evtype_first = evtypes_glob{1};
% Get the signals containing this event type :
[~,~,~,~,~,~,~,~, parentid] = getevents(VI, 'type', evtype_first);
[~,~,~,~,child_desc]        = getsignal(ALLSIG, 'parent', parentid);
[~,~,~,~,parent_desc]       = getsignal(ALLSIG, 'sigid', parentid);

cb_evtypechanged = [
  'evtype_ind = get(findobj(gcbf,''tag'',''evtypes''),''value'');',...
  '[~, ~, evtypes_glob] = getevents(VI, ''chanind'', -1);',...
  'evtypes_glob = unique(evtypes_glob);',...
  'evtype_sel = evtypes_glob(evtype_ind);',...
  '[~,~,~,~,~,~,~,~, parentid] = getevents(VI, ''type'', evtype_sel);',...
  '[~,~,~,~,child_desc]        = getsignal(ALLSIG, ''parent'', parentid);',...
  '[~,~,~,~,parent_desc]       = getsignal(ALLSIG, ''sigid'', parentid);',...
  'set(findobj(gcbf,''tag'',''sigdesc''),''String'',[parent_desc,child_desc]);',...
];

cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;
for w=1:VI.nwin; windowsnb{w}=w; end;

geometry = {[6,1],[3,3,1],[3,3,1],[1],[1, 1],[1],[1,1],[1,1,1,1]};
uilist   = {...
    {},{'Style','text','String','Include'},...
    {'Style','text','String','Event type :'},...
    {'Style','popupmenu','String',evtypes_glob,'tag','evtypes','Callback',cb_evtypechanged},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',[child_desc, parent_desc],'tag','sigdesc'},...
    {},...
    {},...
    {'Style','text','String','Create new signal :'},...
    {'Style','checkbox','Value',1},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'},...
};

results = inputgui (geometry, uilist, 'title', 'Reject Events');
if ~isempty(results)
    evtype_pos  = results{1};
    reject      = ~results{2};
    sig_pos     = results{3};
    newsig      = results{4};
    do_addview     = results{5};
    evtype_sel  = evtypes_glob{evtype_pos};
    winpos      = results{6};
    viewpos     = str2double(results{7});
    % Get the signals containing this event type :
    [~,~,~,~,~,~,~,~, parentid] = getevents(VI, 'type', evtype_sel);
    [~,~,~,~,child_desc]        = getsignal(ALLSIG, 'parent', parentid);
    [~,~,~,~,parent_desc]       = getsignal(ALLSIG, 'sigid', parentid);
    sigdesc = [child_desc,parent_desc];
    sigdesc_sel = sigdesc(sig_pos);
    [~,~,sigid_sel] = getsignal(ALLSIG, 'desc', sigdesc_sel);
    % Reject events that are of the selected type and whose rawparentid is
    % the same than the id of the parent signal of the selected one...
    [~, rawsigid_sel] = getsigrawparent (ALLSIG, sigid_sel);
    events_sel = getevents(VI, 'type', evtype_sel, 'rawpid', rawsigid_sel);
    [VI, ALLWIN, ALLSIG, ~] = rejectevents(VI, ALLWIN, ALLSIG, sigid_sel, events_sel, reject, newsig);
    % Add a view if asked 
    if do_addview
        [VI, ALLWIN, ALLSIG] = addview(VI, ALLWIN, ALLSIG, winpos, ALLSIG(end).id, 't', viewpos);
    end

end






end


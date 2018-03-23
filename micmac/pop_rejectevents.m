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


geometry = {[6,1],[3,3,1],[3,3,1],[1],[2,1,2,1,1]};
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
    {'Style','text','String','Add view :'},...
    {'Style','checkbox','Value',1},...
    {},...
};

results = inputgui (geometry, uilist, 'title', 'Reject Events');
if ~isempty(results)
    evtype_pos  = results{1};
    reject      = ~results{2};
    sig_pos     = results{3};
    newsig      = results{4};
    addview     = results{5};
    evtype_sel  = evtypes_glob{evtype_pos};
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
    [VI, ALLWIN, ALLSIG] = rejectevents(VI, ALLWIN, ALLSIG, sigid_sel, events_sel, reject, newsig);
    
    
end






end


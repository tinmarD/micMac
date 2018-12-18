function [VI, ALLWIN, ALLSIG] = pop_createepochsfromevents (VI, ALLWIN, ALLSIG);
% [VI, ALLWIN, ALLSIG] = POP_CREATEEPOCHSFROMEVENTS (VI, ALLWIN, ALLSIG);
%   Create Epochs Signal from events


[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous');
if isempty(SigCont)
    msgbox ('No signal loaded');
    return;
end

if isempty(VI.eventall)
    msgbox('No events defined');
    return;
end

cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

event_types =  unique({VI.eventall.type});
n_types = length(event_types);

windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;
for w=1:VI.nwin; windowsnb{w}=w; end;

evtype_geo = repmat({[2,1,1]}, 1, length(unique({VI.eventall.type})));
evtype_uilist = {
    {'Style','text','String','Event type'}, ...
    {'Style','text','String',event_types{1}},...
    {'Style','checkbox','Value',1}};
if n_types > 1
    for i_type = 2:n_types
        uilist_type_i = {
            {}, ...
            {'Style','text','String',event_types{i_type}},...
            {'Style','checkbox','Value',1}};
        evtype_uilist = {evtype_uilist{:},uilist_type_i{:}};
    end
end
        
    
    
geometry = {[1,1],evtype_geo{:},[1,1],[1,1],1,[1,1],[1,1,1,1]};
uilist   = {...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',sigdesc},...
    evtype_uilist{:},...
    {'Style','text','String','time pre-onset (s) :'},...
    {'Style','edit','String',''},...
    {'Style','text','String','time post-onset (s) :'},...
    {'Style','edit','String',''},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'},...
};

[results,~] = inputgui (geometry, uilist, 'title', 'Create Epochs from Events');

if ~isempty(results)
    Sig = ALLSIG(results{1});
    
    type_sel_ind = [results{2:1+n_types}];
    type_sel = event_types(logical(type_sel_ind));
    if isempty(type_sel); return; end;        
    
    % Time-pre and time post
    if isempty(results{2+n_types}) || isempty(results{3+n_types})
        return;
    end
    time_pre = str2double(results{2+n_types});
    time_post = str2double(results{3+n_types});
    if isnan(time_pre) || isnan(time_post)
        msgbox('Wrong time parameters');
        return;
    end
    
    [Events, ~, ~] = getevents(VI, 'type', type_sel);
    n_events = length(Events);
    srate = Sig.srate;
    n_points_epoch = round((time_post + time_pre)*srate);
    if n_points_epoch < 1
        msgbox('Wrong time parameters');
        return;
    end
    epoch_data = zeros(n_events, Sig.nchan, n_points_epoch);
    h_wb = waitbar(0,'Epoching Data...','color',vi_graphics('waitbarbackcolor'),'visible','off','name','micMac');
    set(get(findobj(h_wb,'type','axes'),'title'),'color',vi_graphics('textcolor')); set(h_wb,'visible','on');
    for i = 1:n_events
        ev_time_i = Events(i).tpos;
        ev_tstart_i_s = round((ev_time_i-time_pre)*srate);
        ev_tend_i_s = ev_tstart_i_s + n_points_epoch -1;
        epoch_data_i = Sig.data(:, max(1,ev_tstart_i_s):min(Sig.npnts, ev_tend_i_s));
        if ev_tstart_i_s < 1
        	epoch_data(i, :, 1+n_points_epoch-size(epoch_data_i,2):end) = epoch_data_i;
        elseif ev_tend_i_s > Sig.npnts
            epoch_data(i, :, 1:size(epoch_data_i,2)) = epoch_data_i;
        else
            epoch_data(i, :, :) = epoch_data_i;
        end   
        try waitbar(i/n_events,h_wb); catch; end;
    end
    try close(h_wb); catch; end;
    
    %- Add the signal 
    if length(type_sel) == 1
        sig_desc = [Sig.desc,'-',cell2mat(type_sel),'-epoch'];
    else
        sig_desc = [Sig.desc,'-epoch'];
    end
    [VI, ALLWIN, ALLSIG, sigid] = addsignal (VI, ALLWIN, ALLSIG, epoch_data, Sig.channames, ...
        Sig.srate, 'epoch', -time_pre, time_post, Sig.filename, Sig.filepath, Sig.montage, sig_desc, 1, -1, [], []);
    
    %- Add the events with the correponding time 
    for i = 1:n_events
        if -time_pre <= 0 && time_post >= 0
            tpos = time_pre + (i-1) * (time_post + time_pre);
        else
            tpos = 0.5*(time_post + time_pre) + (i-1) * (time_post + time_pre);
        end
         VI = addeventt(VI, ALLWIN, ALLSIG, Events(i).type, tpos, 0, Events(i).channelind, sigid);
    end
    
    % Add a view if asked 
    if results{4+n_types}
        [VI, ALLWIN, ALLSIG] = addview (VI, ALLWIN, ALLSIG, results{5+n_types},sigid,'t',str2double(results{6+n_types}));
    end
end


end
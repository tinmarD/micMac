function [VI, ALLWIN, ALLSIG] = pop_exportfromevents(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_EXPORTFROMEVENTS(VI, ALLWIN, ALLSIG)
%   Pop-up window to export time-period defined by global events. 
%   Can either export the signal defined by the events or "reject" the
%   events, i.e. export the signal between events. 
%   Can choose to merge the signals parts or not
%   Events should be global.
%   Only signals containing at least one event with the selected type are
%   shown in the sigal selection box

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous');
if isempty(SigCont)
    msgbox ('No signal loaded');
    return;
end

[~, ~, evtypes_glob] = getevents(VI, 'chanind', -1);
evtypes_glob = unique(evtypes_glob);
if isempty(evtypes_glob)
    msgbox('Global events should be defined before rejecting events');
    return;
end

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

cb_chansel = [
    'chanselpos = get(gcbf,''userdata'');',...
    'sigdesc    = get(findobj(gcbf, ''tag'', ''sigdesc''),''String'');',...
    'pos        = get(findobj(gcbf, ''tag'', ''sigdesc''),''Value'');',...
    '[~,sigpos] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
    'chanselpos = pop_channelselect(ALLSIG(sigpos),1,1,chanselpos);',...
    'set(findobj(''tag'',''chanseledit''),''String'',[''['',num2str(chanselpos),'']'']);',...
    'set(gcbf,''userdata'',chanselpos);',...
    ];

output_formats = {'.mat','binary (int8)','binary (int16)'};
geometry = {[6,1],[3,3,1],[3,3,1],[3,3,1],[3,3,1],[3,3,1],[1],[1,3,1]};
uilist   = {...
    {},{'Style','text','String','Include'},...
    {'Style','text','String','Event type :'},...
    {'Style','popupmenu','String',evtypes_glob,'tag','evtypes','Callback',cb_evtypechanged},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','sigdesc'},...
    {},...
    {'Style','text','String','Channel list (default All) :'},...
    {'Style','edit','String','','tag','chanseledit'},...
    {},...
    {'Style','text','String','Merge parts'},...
    {'Style','checkbox','Value',0},{},...
    {'Style','text','String','Output format:'},...
    {'Style','popupmenu','String',output_formats},...
    {},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', 'Export Events');
if ~isempty(results)
    % Events
    eventtypepos= results{1};
    evtype_sel  = evtypes_glob{eventtypepos};
    % Get the signals containing this event type :
    [Events_sel,~,~,~,~,~,~,~, parentid] = getevents(VI, 'type', evtype_sel);

    include_ev  = results{2};     
   	sigind      = results{3};
    Sig         = SigCont(sigind);
    ext_str     = output_formats{results{6}};
    chanselman  = results{4};
    %- Channel selection
    if isempty(chanselpos)
        if isempty(chanselman); 
            chanselman=1:Sig.nchan; 
        else
            try
                chanselman = eval(['[',chanselman,']',]);
            catch
                chanselman=1:Sig.nchan;
            end
        end
        chanselman(chanselman<1)=[];
        chanselman(chanselman>Sig.nchan)=[];
        if isempty(chanselman); return; end;
        chanselpos = chanselman;
    end
    
    mergeparts  = results{5};
    if mergeparts
        % If merging is required, just export the whole merged file
        % signal by rejecting/including event parts.
        % Call rejectevents which can construct a new
        [~,~,~,Sig_ev_merged] = rejectevents(VI, ALLWIN, ALLSIG, Sig.id, Events_sel, ~include_ev, 0);
        data_merged = Sig_ev_merged.data(chanselpos, :);
%         EEG_ev_merged = sig2eeg(Sig_ev_merged);
%         EEG_ev_merged = pop_select(EEG_ev_merged,'channel',chanselpos);
        dirname = uigetdir('Select Output Directory');
        out_filename = get_output_filename(Sig_ev_merged.filename, ext_str, Events_sel(1).type, include_ev, mergeparts, 0);
        if dirname
            exportdatasubfun(data_merged, ext_str, dirname, out_filename);
        end
    % else, if user want to eport the file part by part, get the time range
    % of each part from the events and the original file (it differs weither
    % include_ev is 1 or 0 
    else
        dirname = uigetdir('Select Output Directory');
        data_chansel = Sig.data(chanselpos, :);
        for i = 1:length(Events_sel)
            ev_i = Events_sel(i);
            if include_ev
                t_start_i = ev_i.tpos;
                t_end_i = ev_i.tpos+ev_i.duration;
                t_start_i_samp = max(1,round(1+t_start_i*Sig.srate));
                t_end_i_samp = min(round(1+t_end_i*Sig.srate), Sig.npnts);
                if t_start_i > Sig.tmax
                    dispinfo('Event time higher than signal duration');
                else
                    data_part_i = data_chansel(:, t_start_i_samp:t_end_i_samp);
                end
            % Export periods between events
            else
                if i == 1
                    if ev_i.tpos > Sig.tmin
                        t_start_i = 0;
                        t_end_i = ev_i.tpos;
                    else 
                        % First event start at the beggining of the signal
                        continue;                       
                    end
                else
                    t_start_i = Events_sel(i-1).tpos + Events_sel(i-1).duration;
                    t_end_i = ev_i.tpos;
                end
                t_start_i_samp = max(1,round(1+t_start_i*Sig.srate));
                t_end_i_samp = min(round(1+t_end_i*Sig.srate), Sig.npnts);
                if t_end_i > Sig.tmax
                    dispinfo('Event time higher than signal duration');
                else
                    data_part_i = data_chansel(:, t_start_i_samp:t_end_i_samp);
                end
            end
            % Create output filename
            out_filename_i = get_output_filename(Sig.filename, ext_str, Events_sel(1).type, include_ev, mergeparts, i);
            % Export signal part
            exportdatasubfun(data_part_i, ext_str, dirname, out_filename_i);
        end
        % Period between the last event and the end of the signal
        if ~include_ev && (Events_sel(end).tpos + Events_sel(end).duration) < Sig.tmax
            t_start_i = Events_sel(end).tpos + Events_sel(end).duration;
            t_end_i = Sig.tmax;
            t_start_i_samp = max(1,round(1+t_start_i*Sig.srate));
            t_end_i_samp = min(round(1+t_end_i*Sig.srate), Sig.npnts);
            data_part_i = data_chansel(:, t_start_i_samp:t_end_i_samp);
            out_filename_i = get_output_filename(Sig.filename, ext_str, Events_sel(1).type, include_ev, mergeparts, i+1);
            exportdatasubfun (data_part_i, ext_str, dirname, out_filename_i);
        end
    end
end



end


function exportdatasubfun(data, ext_str, output_dir, filename)
    if strcmpi(ext_str,'binary (int8)')
        ext_str = '.dat';
        prec = 'int8';
    elseif strcmpi(ext_str,'binary (int16)')
        ext_str = '.dat';
        prec = 'int16';
    end
    if nargin < 4
        filename = [Sig.desc, ext_str];
    end
%     if strcmpi(ext_str,'.edf')
%         pop_writeeeg(EEG,fullfile(output_dir,filename),'TYPE','EDF');
    if strcmpi(ext_str,'.mat')
        save(fullfile(output_dir,filename),'data'); 
    elseif strcmpi(ext_str,'.dat')
        fid = fopen(fullfile(output_dir,filename),'w');
        fwrite(fid,data,prec);
        fclose(fid);
    end
end


function filename_out = get_output_filename(filename_in, ext_str, event_type, include_ev, merge_parts, i_part)
    filename_out = [];
    if strcmpi(ext_str,'binary (int8)') || strcmpi(ext_str,'binary (int16)')
        ext_str = '.dat';
    end
    if merge_parts
        ext_pos = regexp(filename_in,'\..+$');
        if ~isempty(ext_pos)
            if ~include_ev
                filename_out = [filename_in(1:ext_pos-1),'_',event_type,'_reject_merged',ext_str];
            else
                filename_out = [filename_in(1:ext_pos-1),'_',event_type,'_merged',ext_str];
            end
        else
            if ~include_ev
                filename_out = [filename_in,'_',event_type,'_reject_merged',ext_str];
            else
                filename_out = [filename_in,'_',event_type,'_merged',ext_str];
            end
        end
    else
        ext_pos = regexp(filename_in,'\..+$');
        if ~isempty(ext_pos)
            if ~include_ev
                filename_out = [filename_in(1:ext_pos-1),'_',event_type,'_reject_',num2str(i_part),ext_str];
            else
                filename_out = [filename_in(1:ext_pos-1),'_',event_type,'_',num2str(i_part),ext_str];
            end
        else
            if ~include_ev
                filename_out = [filename_in,'_',event_type,'_reject_',num2str(i_part),ext_str];
            else
                filename_out = [filename_in,'_',event_type,'_',num2str(i_part),ext_str];
            end
        end
    end
end
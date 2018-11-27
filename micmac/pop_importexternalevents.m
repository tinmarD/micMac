function [VI, ALLWIN, ALLSIG] = pop_importexternalevents(VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = pop_importexternalevents(VI, ALLWIN, ALLSIG)

if isempty(ALLSIG)
    msgbox ('You need to load a signal first');
    return;
end

timeUnitList = {'s','ms'};
[rawSigInd,rawSigDesc] = getrawsignals(ALLSIG);

cb_loadeventfile = [
    '[filename,pathname] = uigetfile({''*.txt;*.csv''});',...
    'set (findobj(gcbf,''tag'',''editfilepath''),''string'',fullfile(pathname,filename))'];

cb_global_ev = [
    'glob_ev = get(findobj(gcbf,''tag'',''glob_ev_cb''),''Value'');',...
    'if glob_ev; set (findobj(gcbf,''tag'',''channel_pos_ed''), ''enable'', ''off'');',...
    'else; set (findobj(gcbf,''tag'',''channel_pos_ed''), ''enable'', ''on''); end;',...
    ];

cb_discrete_ev = [
    'glob_ev = get(findobj(gcbf,''tag'',''discrete_ev_cb''),''Value'');',...
    'if glob_ev; set (findobj(gcbf,''tag'',''duration_pos_edit''), ''enable'', ''off'');',...
    'else; set (findobj(gcbf,''tag'',''duration_pos_edit''), ''enable'', ''on''); end;',...
    ];

cb_autodetect = [
    'filepath = get(findobj(gcbf,''tag'',''editfilepath''),''String'');',...
    '[type_col, time_col, chanind_col, duration_col, zero_index, sep] = autodetecteventfields_cb(filepath);',...
    'if type_col~=-1; set(findobj(gcbf,''tag'',''type_pos_edit''),''String'',num2str(type_col)); end;',...
    'if time_col~=-1; set(findobj(gcbf,''tag'',''latency_pos_edit''),''String'',num2str(time_col)); end;',...
    'if chanind_col~=-1; set(findobj(gcbf,''tag'',''channel_pos_ed''),''String'',num2str(chanind_col)); end;',...
    'if duration_col~=-1; set(findobj(gcbf,''tag'',''duration_pos_edit''),''String'',num2str(duration_col)); end;',...
    'if zero_index==1; set(findobj(gcbf,''tag'',''zeroindexcb''),''Value'',1); end;',...
    'if ~isempty(sep); set(findobj(gcbf,''tag'',''file_sep_edit''),''String'',sep); end;',...
    ];

geometry = {[1,2],[1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1],[1,1,1],[1],[3,1]};
uilist   = {...
    {'Style','pushbutton','String','Load event file','Callback',cb_loadeventfile},...
    {'Style','edit','String','              ','tag','editfilepath'},...
    {},...
    {'Style','text','String','Signal'},...
    {'Style','popupmenu','String',rawSigDesc},...
    {'Style','text','String','Separator (Tab: 9)'},...
    {'Style','edit','String',',','tag','file_sep_edit'},...
    {'Style','text','String','Latency Col.'},...
    {'Style','edit','String','1','tag','latency_pos_edit'},...
    {'Style','text','String','Type Col.'},...
    {'Style','edit','String','2','tag','type_pos_edit'},...
    {'Style','text','String','Time unit'},...
    {'Style','popupmenu','String',timeUnitList},...
    {'Style','text','String','Global Events ?'},...
    {'Style','checkbox','value',0,'Callback',cb_global_ev,'tag','glob_ev_cb'},...
    {'Style','text','String','Zero-index for channel ?'},...
    {'Style','checkbox','value',0,'tag','zeroindexcb'},...
    {'Style','text','String','Channel pos. Col.'},...
    {'Style','edit','String','3','tag','channel_pos_ed'},...
    {'Style','text','String','Discrete Events ?'},...
    {'Style','checkbox','value',0,'Callback',cb_discrete_ev,'tag','discrete_ev_cb'},...
    {'Style','text','String','Duration Col.'},...
    {'Style','edit','String','4','tag','duration_pos_edit'},...
    {'Style','text','String','Number of header lines'},...
    {'Style','edit','String','1'},...
    {},...
    {},{'Style','pushbutton','String','Autodetect','Callback',cb_autodetect},{},...
    {},...
    {'Style','text','String','Overwrite Events'},...
    {'Style','checkbox','value',0},...
    };

results = inputgui (geometry, uilist, 'title', 'Import External Events');

if ~isempty(results)
    filepath        = results{1};
    sigPos          = results{2};
    sigId           = ALLSIG(rawSigInd(sigPos)).id;
    sep             = results{3};
    if ~isnan(str2double(sep)) && str2double(sep)==9
        sep = char(9);
    end
    latencyCol      = str2double(results{4});
    typeCol         = str2double(results{5});
    timeUnit        = timeUnitList{results{6}};
    globEv          = results{7};
    chanZeroIndex   = results{8};
    channelCol      = str2double(results{9});
    discreteEv      = results{10};
    durationCol     = str2double(results{11});
    numHeaderLines  = str2double(results{12});
    overwrite       = results{13};
    
    %- Check file exist
    if ~exist(filepath,'file')
        dispinfo('Wrong event filepath');
        return;
    end
    %- Check latency and type col are integers
    if isnan(latencyCol) || isnan(typeCol)
        dispinfo('Latency and type column must be integers')
    end
    %- Check nuber of header lines
    if isnan(numHeaderLines)
        disp('Number of header lines must be and integer');
    end
       
    
    % Open the file in binary mode
    fid = fopen(fullfile(filepath), 'rb');
    % Count the number of lines (i.e. events)
    fseek(fid, 0, 'eof');
    fileSize = ftell(fid);
    frewind(fid);
    % Read the whole file.
    data = fread(fid, fileSize, 'uint8');
    % Count number of line-feeds
    nEvents  = sum(data==10)-numHeaderLines;

    %- Re-open the file
    fid = fopen(fullfile(filepath), 'r');
    %- Read header lines
    while numHeaderLines>0
        fgets(fid);
        numHeaderLines = numHeaderLines-1;
    end

    if overwrite
        VI.eventall = [];
        VI.eventsel = [];
        VI.eventpos = 0;
    end
    
    % Initiate structure
    for i=1:nEvents
        eventLine       = fgets(fid);
        eventValue      = regexp(eventLine,sep,'split');
        if length(eventValue)<max(typeCol,latencyCol)
            dispinfo('Wrong separator, data or position');
            break;
        end
        eventType    	= strtrim(eventValue{typeCol});
        latency         = str2double(eventValue{latencyCol});
        switch timeUnit
            case 'ms'
                latencySec = latency/1000;
            case 's'
                latencySec = latency;
        end
        
        if globEv; chanind_i=-1; else chanind_i=str2double(eventValue{channelCol}); end
        if discreteEv; duration_i=0; else duration_i=str2double(eventValue{durationCol}); end
        if chanZeroIndex; chanind_i = chanind_i + 1; end
        VI = addeventt(VI, ALLWIN, ALLSIG, eventType, latencySec, duration_i, chanind_i, sigId);

    end
    
    % TODO check doublons, check latencies in addeventt()
    VI = updateeventsel (VI,1);    
    [VI, ALLWIN, ALLSIG] = pop_seeevents(VI, ALLWIN, ALLSIG);

end

end


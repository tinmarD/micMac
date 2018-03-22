function [VI, ALLWIN, ALLSIG] = pop_importexternalevents(VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = pop_importexternalevents(VI, ALLWIN, ALLSIG)

if isempty(ALLSIG)
    msgbox ('You need to load a signal first');
    return;
end

timeUnitList = {'ms','s'};
[rawSigInd,rawSigDesc] = getrawsignals(ALLSIG);

cb_loadeventfile = [
    '[filename,pathname] = uigetfile({''*.txt'';''*.csv''});',...
    'set (findobj(gcbf,''tag'',''editfilepath''),''string'',fullfile(pathname,filename))'];

geometry = {[1,2],[1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1],[3,1]};
uilist   = {...
    {'Style','pushbutton','String','Load event file','Callback',cb_loadeventfile},...
    {'Style','edit','String','              ','tag','editfilepath'},...
    {},...
    {'Style','text','String','Signal'},...
    {'Style','popupmenu','String',rawSigDesc},...
    {'Style','text','String','Separator (Tab: 9)'},...
    {'Style','edit','String',','},...
    {'Style','text','String','Latency Col.'},...
    {'Style','edit','String','1'},...
    {'Style','text','String','Type Col.'},...
    {'Style','edit','String','2'},...
    {'Style','text','String','Time unit'},...
    {'Style','popupmenu','String',timeUnitList},...
    {'Style','text','String','Number of header lines'},...
    {'Style','edit','String','1'},...
    {},...
    {'Style','text','String','Overwrite Events'},...
    {'Style','checkbox','value',0},...
    };

results = inputgui (geometry, uilist, 'title', 'Import External Events');

if ~isempty(results)
    filepath        = results{1};
    sigPos          = results{2};
    sigId           = rawSigInd(sigPos);
    sep             = results{3};
    if ~isnan(str2double(sep)) && str2double(sep)==9
        sep = char(9);
    end
    latencyCol      = str2double(results{4});
    typeCol         = str2double(results{5});
    timeUnit        = timeUnitList{results{6}};
    numHeaderLines  = str2double(results{7});
    overwrite       = results{8};
    
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
        VI = addeventt(VI, ALLWIN, ALLSIG, eventType, latencySec, 0, -1, sigId);
    end
    
    % TODO check doublons, check latencies in addeventt(), don't overwrite events

    VI = updateeventsel (VI,1);
    
end

end


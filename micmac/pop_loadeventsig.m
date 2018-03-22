function [VI, ALLWIN, ALLSIG] = pop_loadeventsig (VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_LOADEVENTSIG (VI, ALLWIN, ALLSIG)
%   Allow to load event signals.
%   Filetype must be '.mat'.

[filename, filepath] = uigetfile('.mat', 'Select the .mat file ');
if ~ischar(filename); return; end;
dispinfo ('Loading signal...',1);

errMsg  = ['Could not find the data in the .mat file. The file should either contain',...
    'one matrix or contain a matrix called ''data''.'];
errTitle= 'Error loading event signal';

%% Check formatting of the file
eventSigChannames   = {};
temp                = load(fullfile(filepath,filename));
tempFieldnames      = fieldnames(temp);
if length(tempFieldnames)>2
    if ~ismember('data',tempFieldnames)
        msgbox(errMsg, errTitle); dispinfo (''); return;
    else
        data = temp.data;
    end
else
	data = getfield(temp,tempFieldnames{1});
end
if isstruct(data)
    dataFieldnames = fieldnames(data);
    if ~ismember('time',dataFieldnames) || ~ismember('channel',dataFieldnames)
        msgbox(errMsg, errTitle); dispinfo (''); return;
    else
        if ~isequal(size(data.time),size(data.channel))
            msgbox('Size of time vector and channel indice vector is not equal. Cannot load data',errTitle);
            dispinfo('');
            return;
        end
        eventSigData = [data.time(:),data.channel(:)];
        if ismember('channames',dataFieldnames)
            eventSigChannames = data.channames;
        end
    end
else
    if size(data,2)~=2; data=data'; end;
    if size(data,2)~=2; msgbox('Data matrix should be a matrix of size [nEvents,2]'); dispinfo (''); return; end;
    eventSigData = data;
end
dispinfo ('');

%% Add event signal temporarily
%- Detect the number of 'channels' (or different event types)
nChan = int16(max(eventSigData(:,2)));
%- If channames input is not given, name the channels with number {'channel
%1','channel 2', ...}
if isempty(eventSigChannames)
    eventSigChannames   = cell(1,nChan);
    for i=1:nChan; eventSigChannames{i} = ['channel ',num2str(i)]; end;
end
%- Check that the same file does not already exist
if ~isempty(getsignal(ALLSIG,'filename',filename,'filepath',filepath,'israw',1))
    dispinfo ('Signal already loaded');
    return;
end
%- Pré-remplissage des paramètres
sigdescdef      = fastif(length(filename>4),filename(1:end-4),filename); 
montagedef      = 'undefined';
[~,rawsigdesc]  = getrawsignals(ALLSIG);

%- Add the signal temporarily (to be able to create channel
% correspondences) - with the defaults parameters
[VI, ALLWIN, ALLSIG sigid] = addsignal(VI, ALLWIN, ALLSIG, eventSigData, eventSigChannames, -1, 'eventSig', ...
    filename, filepath, montagedef, sigdescdef, 1, -1, []);
assignin ('base','ALLSIG',ALLSIG);
assignin ('base','VI',VI);

windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;


for w=1:VI.nwin; windowsnb{w}=w; end;
cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

cb_chancorr = [
    'sigpos1     = length(ALLSIG);',...
    'disp(length(ALLSIG));',...
    'sigdesc     = get(findobj(gcbf, ''tag'', ''sigdesclb''),''String'');',...
    'pos         = get(findobj(gcbf, ''tag'', ''sigdesclb''),''Value'');',...
    '[~,sigpos2] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
    '[chancorr, chancorrinv] = pop_chancorr (VI, ALLSIG, sigpos1, sigpos2);',...
    'set(gcbf,''userdata'',struct(''sigpos1'',sigpos1,''sigpos2'',sigpos2',...
    ',''chancorr'',chancorr,''chancorrinv'',chancorrinv));',...
    ];
geometry = {[1,1],[1,1],[1],[2,2,0.5],[1],[1,1],[1,1,1,1]};
uilist   = {...
    {'Style','text','String','Montage type :'},...
    {'Style','edit','String',montagedef},...
    {'Style','text','String','Signal description :'},...
    {'Style','edit','String',sigdescdef,'tag','sigdesc1'},...
    {},...
    {'Style','text','String','Channel correspondency with signal :'},...
    {'Style','popupmenu','String',rawsigdesc,'tag','sigdesclb'},...
    {'Style','pushbutton','String','See','Callback',cb_chancorr},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',1},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'},...
};
if isempty(rawsigdesc)
    geometry = geometry ([1:3,6:7]);
    uilist   = uilist ([1:5,10:15]);
end

[results, userdata] = inputgui (geometry, uilist, 'title', 'Signal description');
if ~isempty(results)
    % Modify the signal
    ALLSIG(end).montage = results{1};
    ALLSIG(end).desc    = results{2};
    % Modify the uimenu
    set (findobj(gcbf,'type','uimenu','Label',sigdescdef),'Label',results{2});
    % Add a view if asked 
    if fastif(isempty(rawsigdesc),results{3},results{4})
        winnb   = fastif (isempty(rawsigdesc),results{4},results{5});
        if isempty(rawsigdesc); viewpos=results{5}; else viewpos=results{6}; end;
        [VI, ALLWIN, ALLSIG] = addview (VI, ALLWIN, ALLSIG, winnb, sigid, 't', viewpos);
    end
    % Add channel correlation if present
    if ~isempty(userdata)
        VI = addchancorr(VI,userdata.sigpos1,userdata.sigpos2,userdata.chancorr,userdata.chancorrinv);
        [ALLWIN] = redrawwin (VI, ALLWIN, ALLSIG);
%         VI.chancorr{userdata.sigpos1,userdata.sigpos2} = userdata.chancorr;
%         VI.chancorr{userdata.sigpos2,userdata.sigpos1} = userdata.chancorrinv;
    end
else
    % Remove the signal
    [VI, ALLWIN, ALLSIG] = deletesignal(VI, ALLWIN, ALLSIG, ALLSIG(end).id);
end

end


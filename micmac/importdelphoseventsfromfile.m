function VI = importdelphoseventsfromfile(VI, ALLSIG)
% VI = IMPORTDELPHOSEVENTSFROMFILE (VI, ALLSIG)
% Import events from a Delphos file. 

if isempty(ALLSIG)
    msgbox('There should be at least one signal loaded into micmac, which must correspond with the associated event file');
    return;
end
if length(ALLSIG) == 1
    sig_pos = 1;
else
    sig_pos = str2double(inputdlg('Signal Position ?'));
end
if isnan(sig_pos)
    msgbox('Signal position must be a number');
    return;
end
if length(ALLSIG) < sig_pos
    msgbox(['Cannot find the signal in position ',num2str(sig_pos)])
    return;
end
delphos_sig = ALLSIG(1);

DELPHOS_SEP     = char(9);
TYPE_COL        = 1;
TIME_COL        = 3;
DURATION_COL    = 4;
CHANNAME_COL    = 5;

[filename, filepath] = uigetfile({'*.mrk;*.csv;*.txt'}, 'Select Events File');
if ~ischar(filepath); return; end;

% Open the file in binary mode
fid = fopen(fullfile(filepath,filename), 'rb');
% Count the number of lines (i.e. events)
fseek(fid, 0, 'eof');
fileSize = ftell(fid);
frewind(fid);
% Read the whole file.
data = fread(fid, fileSize, 'uint8');
% Count number of line-feeds, thus events (2 lines of header)
nevents  = sum(data == 10)-2;
% Close file
fclose(fid);

% Initiate structure
eventlist = repmat (s_emptyevent(), nevents, 1);

% Re-open the file (normal mode)
fid = fopen(fullfile(filepath,filename), 'r');

% Read first 2 line (header)
fgets(fid);
fgets(fid);
% Fill the array structure
if ~isempty(VI.eventall)
    event_id_start = max([VI.eventall.id]);
else
    event_id_start = 0;
end
event_to_delete_pos = [];
for i=1:nevents
    eventline       = fgets (fid);
    eventvalue      = regexp(eventline,DELPHOS_SEP,'split');
    if isequal(eventvalue{TYPE_COL},'p')
        event_to_delete_pos = [event_to_delete_pos, i];
        continue
    end
    % Get the type
    label_i = eventvalue{TYPE_COL};
    freq_str = cell2mat(regexp(label_i,'[\d.,]+Hz','match'));
    if isempty(freq_str)
        eventlist(i).centerfreq = NaN;
    else
        eventlist(i).centerfreq = str2double(freq_str(1:end-2));
        label_pos_end = regexp(label_i,'[\d.,]+Hz');
        label_i = label_i(1:label_pos_end-1);
    end
    eventlist(i).type = label_i;
    eventlist(i).tpos = str2double(eventvalue{TIME_COL});
    eventlist(i).duration = str2double(eventvalue{DURATION_COL});
    channame = strtrim(eventvalue{CHANNAME_COL});
    channame = channame(1:end-1);
    channame = regexprep(channame,' ','');
    eventlist(i).channelname = channame;
    chanind = find(strcmp(delphos_sig.channamesnoeeg,channame));
    if isempty(chanind)
        disp(['Could not find the channel named ', channame])
      
    end
    eventlist(i).channelind = chanind;
    eventlist(i).rawparentid = 1;
    eventlist(i).sigid = delphos_sig.id;
    eventlist(i).sigdesc = delphos_sig.desc;
    eventlist(i).id = event_id_start + i;
    eventlist(i).color = vi_graphics('eventcolor');
end
eventlist(event_to_delete_pos) = [];

if ~isempty(VI.eventall)
    overwrite = questdlg ('Overwrite events ?','Events');
    if strcmp(overwrite,'Yes')
        VI.eventall = eventlist;
        VI.eventsel = eventlist;
    else
        VI.eventall(end+1:end+length(eventlist)) = eventlist;
    end
else
    VI.eventall = eventlist;
    VI.eventsel = eventlist;
end

% TODO check doublons, ask for signal, rewrite all the event ids
VI = updateeventsel (VI, 1);

end


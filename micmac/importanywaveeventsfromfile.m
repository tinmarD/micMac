function VI = importanywaveeventsfromfile(VI, filepath, parent_sig, global_ev, sep, n_header_lines, overwrite)
% VI = IMPORTANYWAVEEVENTSFROMFILE (VI, filepath, parent_sig, global_ev, sep, 
%                                   n_header_lines, overwrite)
% Import events from a Delphos file. 
% Number of header lines (For Delphos event might be 2, for Anywave only 1)

TYPE_COL        = 1;
TIME_COL        = 3;
DURATION_COL    = 4;
CHANNAME_COL    = 5;
COLOR_COL       = 6;

% Open the file in binary mode
fid = fopen(filepath, 'rb');
% Count the number of lines (i.e. events)
fseek(fid, 0, 'eof');
fileSize = ftell(fid);
frewind(fid);
% Read the whole file.
data = fread(fid, fileSize, 'uint8');
% Count number of line-feeds, thus events (minus n_header_lines)
nevents  = sum(data == 10)-n_header_lines;
% Close file
fclose(fid);

% Initiate structure
eventlist = repmat (s_emptyevent(), nevents, 1);

% Re-open the file (normal mode)
fid = fopen(filepath, 'r');

% Read first 2 line (header)
for i=1:n_header_lines
    fgets(fid);
end

% Fill the array structure
if ~isempty(VI.eventall) && ~overwrite
    event_id_start = max([VI.eventall.id]);
else
    event_id_start = 0;
end
% event_to_delete_pos = [];
for i=1:nevents
    eventline       = fgets (fid);
    eventvalue      = regexp(eventline,sep,'split');
%     if isequal(eventvalue{TYPE_COL},'p')        % ???
%         event_to_delete_pos = [event_to_delete_pos, i];
%         continue
%     end
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
    % Channel name 
    if (length(eventvalue) >= CHANNAME_COL) && ~global_ev
        channame = strtrim(eventvalue{CHANNAME_COL});
        channame = channame(1:end-1);   % Remove the ',' at the end (always present ?)
        channame = regexprep(channame,'EEG','');  % Remove the 'EEG' if present
        channame = regexprep(channame,' ','');  
        chanind = find(strcmp(parent_sig.channamesnoeeg,channame));
        if isempty(chanind)
            warning(['Could not find the channel named ', channame])
            warning('Event channelname is set to all');
            eventlist(i).channelname = 'all';
            eventlist(i).channelind  = -1;
        else
            eventlist(i).channelname = channame;
            eventlist(i).channelind  = chanind; 
        end
    else
        eventlist(i).channelname = 'all';
        eventlist(i).channelind  = -1;
    end
    % Color 
    if length(eventvalue) >= COLOR_COL
        try
            eventlist(i).color = hex2rgb(eventvalue{COLOR_COL});
        catch
            eventlist(i).color = vi_graphics('eventcolor');
        end
    else
        eventlist(i).color = vi_graphics('eventcolor');
    end
    eventlist(i).rawparentid = 1;
    eventlist(i).sigid = parent_sig.id;
    eventlist(i).sigdesc = parent_sig.desc;
    eventlist(i).id = event_id_start + i;

end
% eventlist(event_to_delete_pos) = [];

if ~isempty(VI.eventall)

    if overwrite
        VI.eventall = eventlist;
        VI.eventsel = eventlist;
    else
        VI.eventall(end+1:end+length(eventlist)) = eventlist;
    end
else
    VI.eventall = eventlist;
    VI.eventsel = eventlist;
end

end


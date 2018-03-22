function VI = importeventsfromfile(VI, externalCall)
% VI = IMPORTEVENTSFROMFILE (VI, externalCall)
% Import events from a file. 

if nargin==1
    externalCall = 0;
end

[filename, filepath] = uigetfile({'*.csv;*.txt'}, 'Select Events File');
if ~ischar(filepath); return; end;

% Open the file in binary mode
fid = fopen(fullfile(filepath,filename), 'rb');
% Count the number of lines (i.e. events)
fseek(fid, 0, 'eof');
fileSize = ftell(fid);
frewind(fid);
% Read the whole file.
data = fread(fid, fileSize, 'uint8');
% Count number of line-feeds
nevents  = sum(data == 10)-1;
% Read the event fieldnames (first line)
frewind(fid);
fieldnamesline  = fgets (fid);
eventfields     = strtrim(regexp(fieldnamesline,',','split'));
% Compare the eventfields of the file with the current version 
addNaNCenterFreq= 0;
addColor        = 0;
if ~isempty(find(ismember(fieldnames(s_emptyevent),eventfields)==0,1))
    if ~ismember('centerfreq',eventfields)
        addNaNCenterFreq    = 1;
        eventfields         = [eventfields,'centerfreq'];
    end
    if ~ismember('color',eventfields)
        addColor            = 1;
        eventfields         = [eventfields,'color'];
    end
    if length(eventfields)~=length(fieldnames(s_emptyevent))
        error('Event fields appear to have changed');
    end
end
nfields         = length(fieldnames(s_emptyevent));
% Close file
fclose(fid);


% Initiate structure
eventlist = repmat (s_emptyevent(), nevents, 1);

% Re-open the file (normal mode)
fid = fopen(fullfile(filepath,filename), 'r');

% Read first line (fieldnames)
fgets(fid);
% Fill the array structure
for i=1:nevents
    eventline       = fgets (fid);
    eventvalue      = regexp(eventline,',','split');
    if addNaNCenterFreq
        eventvalue = [eventvalue,'NaN'];
    end
    for j=1:nfields
        if ismember(eventfields{j},{'type','channelname','sigdesc'})
            eventlist(i) = setfield (eventlist(i),eventfields{j},eventvalue{j});
        elseif ismember(eventfields{j},{'id','tpos','duration','channelind','sigid','rawparentid','centerfreq'})
            eventlist(i) = setfield (eventlist(i),eventfields{j},str2double(eventvalue{j}));
        elseif strcmp(eventfields{j},'color')
            if addColor
                eventlist(i).color = vi_graphics('eventcolor');
            else
                [r,g,b] = strread(eventvalue{j},'%f %f %f','delimiter',' ');
                eventlist(i).color = [r,g,b];
            end
        else
            error (['Unknown field name: ',eventfields{j}]);
        end
    end
end

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

VI = updateeventsel (VI,externalCall);

end


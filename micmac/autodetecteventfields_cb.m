function [type_col_sel, time_col_sel, chanind_col_sel, duration_col_sel, zero_index_chan, sep_sel] = autodetecteventfields_cb(filepath)
% [type_col_sel, time_col_sel, chanind_col_sel, duration_col_sel, 
%  zero_index_chan, sep_sel] = AUTODETECTEVENTFIELDS_CB(filepath)
%   Read an external event files and search the type column, the time
%   column, the channel index column and the duration column based on the 
%   header (first line of the file). For the detection to work, the first
%   line must contain the columns name
%    - Type column should be named 'type'
%    - Time column should be named 'time', 'tpos', 'latency' 
%    - Channel index column should be named 'channelind', 'chind',
%    'chanind', 'channel', 'chan'
%    - Duration column should be named 'duration', 'durée', 'duree'

type_col_sel=-1; time_col_sel=-1; chanind_col_sel=-1; duration_col_sel=-1;
zero_index_chan = 0;

type_cols = {'type'};
time_cols = {'tstart','time','tpos','latency','t_pos','t_start'};
chanind_cols = {'channelind','chind','chanind', 'channel', 'chan'};
duration_cols = {'duration','durée','duree'};

%- Check file exist
if ~exist(filepath,'file')
    msgbox('Wrong event filepath');
    return;
end

%- open the file
fid = fopen(fullfile(filepath), 'r');
%- Read first lines
header = fgets(fid);

%- Try to detect the separator between [tab, ',', ';', space]
seps = {char(9), ',', ';', ' '};
sep_sel_pos = [];
sep_sel = '';
for sep = seps
    sep_pos_i = strfind(header,sep{1});
    if length(sep_pos_i) > length(sep_sel_pos)
        sep_sel_pos = sep_pos_i;
        sep_sel = sep{1};
    end
end
if isempty(sep_sel_pos)
    msgbox('Could not determine the separator');
end

header_fields = regexp(header,sep_sel,'split');

%- Go through each column name and see if it match one of the needed fields
for i = 1:length(header_fields)
    type_col = cell2mat(regexp(header_fields{i}, type_cols));
    time_col = cell2mat(regexp(header_fields{i}, time_cols));
    chanind_col = cell2mat(regexp(header_fields{i}, chanind_cols));
    duration_col = cell2mat(regexp(header_fields{i}, duration_cols));
    if ~isempty(type_col)
        type_col_sel = i;
    end
    if ~isempty(time_col)
        time_col_sel = i;
    end
    if ~isempty(chanind_col)
        chanind_col_sel = i;
    end
    if ~isempty(duration_col)
        duration_col_sel = i;
    end
end

% Read channel ind column if found and try to detect if channel are 0-indexed
if chanind_col_sel ~= -1
    line = fgets(fid);
    while ischar(line)
        line_fields = regexp(line,sep_sel,'split');
        chan_pos = line_fields{chanind_col_sel};
        if chan_pos == 0; zero_index_chan = 1; end
        line = fgets(fid);
    end
end


end


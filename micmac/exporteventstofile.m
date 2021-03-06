function  [] = exporteventstofile (VI, dirpath, filename)
% [] = EXPORTEVENTTOFILE (VI)
% Export events to a file (.txt or .csv). Ask the user for a location to
% save the file

if isempty (VI.eventall); return; end;

if nargin < 3
    [filename, dirpath] = uiputfile({'*.csv;*.txt'}, 'Select File for Saving Events');
    if ~ischar(dirpath); return; end;
else
    if ~isdir(dirpath)
        try
            mkdir(dirpath);
        catch
            warning(['Cannot create directory : ',dirpath]);
            dirpath = '.';
        end
    end
end

eventfields = fieldnames(VI.eventall(1));
nfields     = length(eventfields);

% Open the file
try
    fid = fopen (fullfile(dirpath,filename),('w+t'), 'n');
catch
    error(['Cannot open file ', fullfile(dirpath,filename)]);
end
% In header write the fields name
for j=1:nfields
    fprintf (fid,'%s',eventfields{j});
    if j~=nfields; fprintf (fid,','); end
end

fprintf (fid,'\n');

if isempty (VI.eventall); return; end;
for i=1:length(VI.eventall);
    eventi = VI.eventall(i);
    for j=1:nfields
        fieldstr = getfield (eventi,eventfields{j});
        fieldstr = fastif (ischar(fieldstr),fieldstr,num2str(fieldstr));
        fprintf (fid,fieldstr);
        if j~=nfields; fprintf (fid,','); end
    end
    fprintf (fid,'\n');
end

% Close the file
fclose (fid);

end


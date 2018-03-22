function [] = eventui_celledit(~, cbdata)
% Used to modify the type of an event from the table

seleventid      = evalin('base',['VI.eventsel(',num2str(cbdata.Indices(1)),').id;']);
% Get the position of the selected event in the VI.eventall array
[~,seleventpos] = evalin('base',['getevents (VI,''eventid'',',num2str(seleventid),');']);
seleventpos     = find (seleventpos==1);

% Modify the event in VI.eventall in the base workspace
evalin ('base',['VI.eventall(',num2str(seleventpos),').type = ''',cbdata.NewData,''';']);
% Update events table
evalin ('base','VI = updateeventsel (VI, 1);');

end


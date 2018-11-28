 function VI = addmneepochevents (VI, ALLWIN, ALLSIG, MNEepoch, sigid)
     n_events = size(MNEepoch.events,1);
     event_dict = strsplit(MNEepoch.event_id,';');
     for i = 1:n_events
         if MNEepoch.tmin <= 0 && MNEepoch.tmax >= 0
             tpos = -MNEepoch.tmin + (i-1) * (MNEepoch.tmax - MNEepoch.tmin);
         else
             tpos = 0.5*(MNEepoch.tmax - MNEepoch.tmin) + (i-1) * (MNEepoch.tmax - MNEepoch.tmin);
         end
         eventid_i = MNEepoch.events(i,3);
         duration = 0.2;
         chanind = -1;
         eventType = findeventtype(event_dict, eventid_i);
         VI = addeventt(VI, ALLWIN, ALLSIG, eventType, tpos, duration, chanind, sigid);
     end
 end
 
function eventtype = findeventtype(event_dict, id_num)
    eventtype = '';
    for i=1:length(event_dict)
        if ~isempty(regexp(event_dict{i},['.*:',num2str(id_num),'$']))
            eventtype = cell2mat(regexp(event_dict{i},'.*:','match'));
            eventtype = eventtype(1:end-1);
        end           
    end
end
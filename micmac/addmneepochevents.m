 function VI = addmneepochevents (VI, ALLWIN, ALLSIG, MNEepoch, sigid)
 
 n_events = size(MNEepoch.events,1);
 for i = 1:n_events
     if MNEepoch.tmin <= 0 && MNEepoch.tmax >= 0
         tpos = -MNEepoch.tmin + (i-1) * (MNEepoch.tmax - MNEepoch.tmin);
     else
         tpos = 0.5*(MNEepoch.tmax - MNEepoch.tmin) + (i-1) * (MNEepoch.tmax - MNEepoch.tmin);
     end
     duration = 0.2;
     chanind = -1;
     eventType = 'Trial';
     VI = addeventt(VI, ALLWIN, ALLSIG, eventType, tpos, duration, chanind, sigid);
 end
 
 end
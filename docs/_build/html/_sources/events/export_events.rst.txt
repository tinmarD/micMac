******************************
       Exporting Events
******************************

To export events, open the event panel (*Ctrl E*) and use the export button.

.. figure:: /_images/events_export.png
   :align: center

It will export the micMac events in a csv file. The different fields of the csv file are : 

 - id : ID of the event
 - type : The type of event
 - tpos : The latency of the event in seconds (onset time)
 - duration : The duration of the event in seconds
 - channelind : The number of the channel - Indexing starts at 1.
 - channelname : The name of the channel. 
 - sigid : The ID of the signal associated with the event
 - sigdesc : The description of the signal associated with the event
 - rawparentid : The raw parent ID of the signal associated with event
 - centerfreq : If estimated, the central frequency of the event signal

Not all these fields are relevants, but all are used by micMac for internal processing. 



******************************
       Importing Events
******************************

Events can be imported into micMac using the *Events/Import* menu.

micMac can import events from : 

 - micMac - when events are saved from micmac (*.csv, *.txt)
 - Anywave/Delphos (*.mrk, *.csv, *.txt)
 - External events 

Use the *Events/Import/External events* to open the following window : 

.. figure:: /_images/events_import_external.png
   :align: center

The fields are : 

 - The *Latency* column should give the time of each event, select the *Time unit* according to it, which can be in seconds or milliseconds.
 - The *Type* column gives the type/name of each event.
 - The *Channel pos* column should give the channel number. 
 - The *Duration* column gives the duration of the events.

If events are defined for all channels, check the *Global Events ?* checkbox. If the first channel is indexed by 0, check the *Zero-index for channel?*.

The *Autodetect* button will try to detect automatically the position of each column.

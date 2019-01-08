*******************
    Export Data
*******************

Export whole file
------------------

This functionnality allows to export data from a signal in an matlab format (*.mat*). 

Go to **Signals>Export>Export data**. The following window appears:

.. figure:: /_images/signals_export_data_popup.png
   :align: center
   
Parameters are :

 - **Signal** : Signal to export data from
 - **Chanel list** : Matlab vector indicating the list of channels to export. By default, all channels will be exported.
 - **Data range** : Two-elements vector indicating the temporal range of data to export. By default, the whole time range is selected. 

Each channel is saved in a seperate file. All the files are automatically stored in a folder named after the signal's description. Once imported into Matlab, the data appears into a matlab matrix named *data*.

.. note:: 

   This way of exporting data allows to load them easily into **Wave_clus** for action potential detection and sorting.

Export from global events
-------------------------

This menu allow you to extract or reject the signal defined by global events and export it. 

.. figure:: /_images/signals_export_from_events.png
   :align: center

Select the type of event you want to reject or select. If you need to include the events parts, check the Include checkbox. Select the signal from which the data will be extracted. Check the *Merge* button to merge all the event parts together (or the part between events). 

Then select the output format (*.mat*, or binary) and the output directory. The different parts of the signal correponding to the events (or between events) will be saved : 

.. figure:: /_images/signals_export_from_events_res.png
   :align: center

.. note::
   This is similar to the *Events/Reject Events* tool, with in addition the possibility to merge and export the signal parts defined by the events



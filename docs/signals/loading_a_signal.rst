************************
    Loading a signal
************************

Go to **Signals>Load raw signal** to load a new signal or use the **Ctrl O** shortcut. After selecting the file, the following window shows up :

.. figure:: /_images/signals_load_popup.png
   :align: center
   :width: 75%

The fields are :

 - **Montage type** : indicates weither the montage is monopolar or bipolar
 - **Signal description** : name identifying the signal. It can be modified later on.
 - **Channel correspondency with signal** : if more than one signal is loaded, this tool allow to indicates the channel correspondency between the different signals (See LINK). 
 - **Add view** : If checked, a temporal view of the signal will be added. On by default.
 - **Window** : If a view is added, this is the number of the window where to add it. 
 - **Position** : Position of the view in the window.

.. note:: 

   For now only EDF files can be imported into micMac. EEGLAB can be used to do the data conversion if the format does not match this one. 

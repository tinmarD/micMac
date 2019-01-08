************************************
       Signals Synchronization
************************************

This function can be used to synchronize two signals that are linked but out of synched. Let's take the case of 2 signals, one signal correponding to Macro electrodes and a second signals correponding to micro electrodes. 

.. figure:: /_images/signals_resynch_ex.png
   :align: center

The Macro signal is at the top and the micro signal at the bottom. These two signals record the same activity at different scales but are out of synched. 

Open the Re-synch panel in **Signals/Re-synch signals** : 

.. figure:: /_images/signals_resynch.png
   :align: center

Select the two signals which need to be synched, and two correponding channels. Select a large time window and max lag. If the time offset in larger than the max lag the synchronization will not work. 

You can choose a resampling frequency to improve the time resolution.

Click the *Run Analysis* button to get the time offset between the 2 signals. It will estimate the lag using a cross-correlation. 

.. figure:: /_images/signals_resynch_res.png
   :align: center

If the time offset is already known, you can specify it in the *Known time offset* box.  

You can choose to either cut the beginning of the signal starting earlier of the add a blank signal before the signal starting later. 

.. figure:: /_images/signals_resynch_synch_sigs.png
   :align: center


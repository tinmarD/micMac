******************
   Add a view 
******************

To add a view, go to **Views/Add View**. The following appears:

.. figure:: /_images/view_add_view_t.png
   :align: center
   :width: 70%

   Temporal domain

Parameters are:

 - **Signal** : Signal associated with the view.
 - **Domain** : Domain of visualisation. Can be time, frequency, or time-frequency.
 - **Window** : Number of the window where to add it. 
 - **Position** : Position of the view in the window.

For frequency domain views, i.e. power spectrum representation,

.. figure:: /_images/view_add_view_f.png
   :align: center
   :width: 70%

   frequency domain

additional parameters are : 

 - **freq min** : Minimum frequency visualised frequency.
 - **freq max** : Maximum frequency visualised frequency.



For time-frequency domain views,

.. figure:: /_images/view_add_view_tf.png
   :align: center
   :width: 70%

   time-frequency domain

additional parameters are : 

 - **wavelet name** : name of wavelet. By default micMac uses a Complex Morlet wavelet (*cmor1-1.5*).
 - **freq min** : Minimum pseudo-frequency visualised frequency.
 - **freq max** : Maximum pseudo-frequency visualised frequency.
 - **freq step** or **num freqs** : Step between two pseudo-frequencies OR the number of frequencies (when Log scale is on) 
 - **Log** : If on, the frequency scale increases logarithmically.

Phase views share the same parameter as the time-frequency views.

.. note:: 
   Frequency domain, time-frequency, and phase domain views do not appears on **Stacked mode** (visualisation mode 1). Select the **Spaced mode** to visualise them.  




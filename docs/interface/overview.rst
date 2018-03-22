********************
      Overview
********************

When starting micMac, the following interface appears. On the bottom are the controls for moving in time and zooming. On the left side are the channel selection, gain and view mode controls. Menus are on top.

.. figure:: /_images/interface_blank_gui.png
   :align: center

   Blank micMac interface

Principles
----------

micMac works with three basic objects, **Signals**, **Views** and **Windows**. 

A signal is a matlab structure (similar to an EEGLAB dataset) representing a signal. It contains the data, the sampling frequency, the channel names... Signals can be filtered, thresholded or transformed with other operators to create child signals.

Views allow to observe these signals. A view is associated with a signal, a visualisation domain, a color, and a gain. The visualisation domain is one of the following:

 - Temporal - Observe the signal in the time domain
 - Frequency - Uses a Fourier transform to observe the spectrum over the whole time window. 
 - Time-Frequency - Uses a wavelet transform to represent the frequency content over time. 

Windows are where views are placed. Each window can have multiples views. The main window is the leading window, the other windows can synchronize with it.

.. warning::
  
   Closing the main window will close the whole program.

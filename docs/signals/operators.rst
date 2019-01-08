******************************
       Operators
******************************

Thresholding
------------

Threshold a signal and creates events.

.. figure:: /_images/signals_threshold_popup.png
   :align: center

A minimum threshold T_min and maximum threshold T_max must be specified. All time points whose amplitude lie between these two threshold : $$T_{min} < x < T_{max}$$ will be selected.

Events will be created for each of the thresholded parts.

You can see the amplitude distribution across all channels and time points by clicking on the **Amplitude Distribution** button.


Teager Energy Operators
------------------------

The Teager Energy Operator (TEO) is a non-linear operator. It has been used in EEG to detect interictal epileptic discharges or action potential. See : *Neural action potential detector using multi-resolution TEO - J.H. Choi and T. Kim*.

The discrete time TEO can be expressed as : 
$$ \Phi(x(n)) = x^2(n) - x(n-1)x(n+1) $$

The k-TEO is a generalization of the TEO : 
$$ \Phi_k(x(n)) = x^2(n) - x(n-k)x(n+k) $$

The k parameter must be choosed according to the type of detection wanted and the sampling frequency of the signal. 

The MTEO operator is a parallel association of several k-TEO operators with differents values of k, followed by a maximum filter.

.. note::

   An IED detector based on the MTEO operator is available in micMac in the *Detectors/Epileptic Spike* menu, although it has not been tested thoroughly.

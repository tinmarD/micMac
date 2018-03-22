function micmac( varargin )
%micMac Ver-1.5
% New 1-5:
% - Rainbow color (enabled with right click on T views)
% - New montage - Can create signal with a new montage from a monopolar raw
% signal (Output signal can be bipolar, average, or electrode-average)
% - New colorscheme
% - New function for cleaning line noise (using PrepPipeline functions)
% - NEW type of signal: event signal. Allows to visualize events as a
% signal. Used for example to visualize action potentials.
%
% Modified:
% - function pop_chansel is replaced by pop_channelselect to avoid conflict
% with EEGLAB function
%
%%New 1-4: 
    % - Channel selection popup for detectors and data export
    % - Colormap can be changed with a right click on T-F views
    % - Possibility to hide events (with menu or shortcut h)
    % - Can open NSX files
    % - Improved wavelet time-frequency with new normalisation methods
    % - Improved view properties panel (pop_viewproperty)
    %  
    % Modified :
    % - Use a Tukey window instead of a Hamming window for removing edge
    % effects in wavelet scalogram
    %
    % Removed :
    % - Smooth end of signal function
    % - Own Staba detector implementation 

%% 
%- if another version of the gui is open, close it
oldfigh =  findobj ('Type','figure','Name','micMac v. 1.5');
if ~isempty(oldfigh)
    delete(oldfigh);
end
% TODO not working clean workspace and figures
evalin('base','clear all; close all;');
evalin('base','vi_global;');
evalin('base','[VI,ALLSIG] = vi_initglobal (VI,ALLSIG);');

f = micmac_mainfig (1);

set (f,'Visible','on');

end





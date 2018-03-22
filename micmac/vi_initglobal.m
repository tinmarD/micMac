function [VI,ALLSIG] = vi_initglobal (VI,ALLSIG)
% [VI,ALLSIG] = VI_INITGLOBAL (VI,ALLSIG)
%   Initialize the global variables of VI structure

VI.nwin     = 0;
VI.sigid    = 0;
VI.viewid   = 0;
VI.eventid  = 0;
VI.figh     = [];
VI.chancorr = {};
VI.eventall = [];
VI.eventsel = [];
VI.eventpos = 0;
% Cursor struct
VI.cursor.hlastcursor   = []; % handle of last cursor 
VI.cursor.hfirstcursor  = []; % handle of first cursor (to be deleted later)
VI.cursor.firstcursorval= []; % To save the first cursor value
VI.cursor.type          = 0;
VI.cursor.inc           = 0;
VI.cursor.haxis         = [];
%- GUI Parameters
% AddEventOptions
VI.guiparam.addevent.type       = '';
VI.guiparam.addevent.channel    = 'channel';
% SeeEvents
VI.guiparam.seeevents.order1            = '';
VI.guiparam.seeevents.order2            = '';
VI.guiparam.seeevents.order3            = '';
VI.guiparam.seeevents.seltype           = 'All';
VI.guiparam.seeevents.selsignal         = 'All';
VI.guiparam.seeevents.selchannel        = 'All';
VI.guiparam.seeevents.seltypeexval      = 0;
VI.guiparam.seeevents.selsignalexval    = 0;
VI.guiparam.seeevents.selchannelexval   = 0;
VI.guiparam.seeevents.selectallval      = 0;
%- Hide Events
VI.guiparam.hideevents                  = 0;
%- DisplayEventInformation
VI.guiparam.dispeventinfo               = 0;
%- Default colormap
VI.guiparam.colormap                    = vi_defaultval('colormap');
function f = micmac_mainfig (ismain)

% Will not work for matlab 2015 and higher? Replace ResizeFcn with SizeChangedFcn
fresize_cb = ['figpos = get(gcbf,''Position'');',...
'csel           = findobj(''parent'',gcbf,''tag'',''chansellb'');',...
'cseltext       = findobj(''parent'',gcbf,''tag'',''chanseltext'');',...
'cselsel        = findobj(''parent'',gcbf,''tag'',''chanselsel'');',...
'mit_p          = findobj(''parent'',gcbf,''tag'',''mitp'');',...
'zoom_p         = findobj(''parent'',gcbf,''tag'',''zoomp'');',...
'gain_p         = findobj(''parent'',gcbf,''tag'',''gainp'');',...
'obswint_p      = findobj(''parent'',gcbf,''tag'',''obswintp'');',...
'syncctimettext = findobj(''parent'',gcbf,''tag'',''syncctimettext'');',...
'syncctimetcb   = findobj(''parent'',gcbf,''tag'',''syncctimetcb'');',...
'ctimetoverlaycb= findobj(''parent'',gcbf,''tag'',''ctimetoverlaycb'');',...
'visumodebg     = findobj(''parent'',gcbf,''tag'',''visumodebg'');',...
'syncobstimettext   = findobj(''parent'',gcbf,''tag'',''syncobstimettext'');',...
'syncobstimetcb     = findobj(''parent'',gcbf,''tag'',''syncobstimetcb'');',...
'syncchancb         = findobj(''parent'',gcbf,''tag'',''syncchancb'');',...
'set (cseltext,''Units'',''pixels'',''Position'',[5,0.7*figpos(4)+5,80,15]);',...
'set (csel,''Units'',''pixels'',''Position'',[5,0.2*figpos(4),100,0.5*figpos(4)]);',...
'set (cselsel,''Units'',''pixels'',''Position'',[10,0.2*figpos(4)-30,80,25]);',...
'set (gain_p,''Units'',''pixels'',''Position'',[5,0.7*figpos(4)+100,100,65]);',...
'set (mit_p,''Units'',''pixels'',''Position'', [0.4*figpos(3),5,0.2*figpos(3),40]);',...
'set (zoom_p,''Units'',''pixels'',''Position'', [0.7*figpos(3)-50,5,100,40]);',...
'set (obswint_p,''Units'',''pixels'',''Position'',[0.15*figpos(3),5,0.2*figpos(3),40]);',...
'set (syncctimettext,''Units'',''pixels'',''Position'',[0.6*figpos(3)+5,27,25,15]);',...
'set (syncctimetcb,''Units'',''pixels'',''Position'',[0.6*figpos(3)+10,15,15,15]);',...
'set (syncobstimettext,''Units'',''pixels'',''Position'',[0.35*figpos(3)+5,27,25,15]);',...
'set (syncobstimetcb,''Units'',''pixels'',''Position'',[0.35*figpos(3)+10,15,15,15]);',...
'set (visumodebg,''Units'',''pixels'',''Position'',[5,max(0.95*figpos(4),0.7*figpos(4)+160),100,30]);',...
'set (syncchancb,''Units'',''pixels'',''Position'',[85,0.7*figpos(4)+5,15,15]);',...
'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);',...
'clear csel cseltext cselsel mit_p gain_p obswint_p syncctimettext syncctimetcb ctimetoverlaycb;',...
'clear visumodebg syncobstimettext syncobstimetcb syncchancb;',...
];

if ismain
    fdelete_cb = [
        'try;',...
        'if isempty([ALLWIN.views]) || vi_questui(''Quit micMac'',''micMac'')==1;',...
        'for h=VI.figh;delete(h);end;',...
        'eventwin = findobj(''tag'',''eventwindow'');',...
        'if ~isempty(eventwin); delete(eventwin); end;'...
        'clear VI ALLSIG ALLWIN h; end;',...
        'catch; delete(gcbf); end;',...
        ];
else
    fdelete_cb = [
        'VI.nwin=VI.nwin-1; winnb=find(cat(1,ALLWIN.figh)==gcbf);',...
        'delete(gcbf);',...
     	'VI.figh(winnb)=[];ALLWIN(winnb)=[];'];
end

figpos = vi_graphics('figposition');

%- create main figure
f = figure('Visible','off','Position',figpos,'DockControls','off',...
            'MenuBar','none','Name','micMac v. 1.5','NumberTitle','off',...
            'CloseRequestFcn',['try;',fdelete_cb,'end;'],...
            'KeyPressFcn','','ResizeFcn',fresize_cb,'Color',vi_graphics('backgroundcolor'));
        
set(f,'WindowButtonDownFcn','[VI, ALLWIN] = vi_buttondowncb (VI, ALLWIN);');

%- Keyboard shortcuts
cb_keypressed = '[VI, ALLWIN, ALLSIG] = keypressedcb (VI, ALLWIN, ALLSIG);';
set(f,'WindowKeyPressFcn',cb_keypressed);

if 1%ismain 
    
    assignin('base','f',f);
    evalin  ('base','[VI, ALLWIN]=addwindow(VI,ALLWIN,f);');
    evalin  ('base','clear f');
    
    %- menu callbacks
    cb_loadrawsigedf    = '[VI, ALLWIN, ALLSIG] = pop_loadrawsig        (VI, ALLWIN, ALLSIG, ''EDF'');';
    cb_loadrawsigns5    = '[VI, ALLWIN, ALLSIG] = pop_loadrawsig        (VI, ALLWIN, ALLSIG, ''NS5'');';
    cb_loadrawsigfif    = '[VI, ALLWIN, ALLSIG] = pop_loadrawsig        (VI, ALLWIN, ALLSIG, ''FIF'');';
    cb_loadeventsig     = '[VI, ALLWIN, ALLSIG] = pop_loadeventsig      (VI, ALLWIN, ALLSIG);';
    cb_exportdata       = '[VI, ALLWIN, ALLSIG] = pop_exportdata        (VI, ALLWIN, ALLSIG);';
    cb_exportdatatoedf  = '[VI, ALLWIN, ALLSIG] = pop_exportdatatoedf   (VI, ALLWIN, ALLSIG);';
    cb_filtersig        = '[VI, ALLWIN, ALLSIG] = pop_filtersignal      (VI, ALLWIN, ALLSIG);';
    cb_newmontage       = '[VI, ALLWIN, ALLSIG] = pop_newmontage        (VI, ALLWIN, ALLSIG);';
    cb_kteooperator     = '[VI, ALLWIN, ALLSIG] = pop_kteooperator      (VI, ALLWIN, ALLSIG);';
    cb_mteooperator     = '[VI, ALLWIN, ALLSIG] = pop_mteooperator      (VI, ALLWIN, ALLSIG);';
    cb_threshold        = '[VI, ALLWIN, ALLSIG] = pop_threshold         (VI, ALLWIN, ALLSIG);';
    cb_extractspikes    = '[VI, ALLWIN, ALLSIG] = pop_extractspikes     (VI, ALLWIN, ALLSIG);';
    cb_cleanlinenoise   = '[VI, ALLWIN, ALLSIG] = pop_cleanlinenoise    (VI, ALLWIN, ALLSIG);';
    cb_markbadchannels  = '[VI, ALLWIN, ALLSIG] = markbadchannels       (VI, ALLWIN, ALLSIG);';
    cb_seteegchannels   = '[VI, ALLWIN, ALLSIG] = pop_seteegchannels    (VI, ALLWIN, ALLSIG);';
    cb_addview          = '[VI, ALLWIN, ALLSIG] = pop_addview           (VI, ALLWIN, ALLSIG);';
    cb_addwindow        = '[VI, ALLWIN]         = addwindow             (VI, ALLWIN);';
    cb_seeevents        = '[VI, ALLWIN, ALLSIG] = pop_seeevents         (VI, ALLWIN, ALLSIG);';
    cb_hideevents       = ['VI.guiparam.hideevents    = ~VI.guiparam.hideevents;     ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);',...
    	'if VI.guiparam.hideevents; set(gcbo,''label'',''Display Events''); else; set(gcbo,''label'',''Hide Events''); end;'];
    cb_dispeventinfo    = 'VI.guiparam.dispeventinfo = ~VI.guiparam.dispeventinfo;  ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);';
    cb_addevent         = '[VI, ALLWIN, ALLSIG] = pop_addevent          (VI, ALLWIN, ALLSIG);';
    cb_addeventoptions  = '[VI, ALLWIN, ALLSIG] = pop_addeventoptions   (VI, ALLWIN, ALLSIG);';
    cb_freqestimation   = '[VI, ALLWIN, ALLSIG] = freqestimation        (VI, ALLWIN, ALLSIG);';
    cb_importmicmacevents= 'VI                  = importeventsfromfile  (VI,1);';
    cb_importanywaveevents='VI                  = importanywaveeventsfromfile  (VI, ALLSIG);';
    cb_importextevents  = '[VI, ALLWIN, ALLSIG] = pop_importexternalevents(VI,ALLWIN,ALLSIG);';
    cb_rejectevents     = '[VI, ALLWIN, ALLSIG] = pop_rejectevents(VI,ALLWIN,ALLSIG);';
    cb_previousevent    = '[VI, ALLWIN, ALLSIG] = navigateevent         (VI, ALLWIN, ALLSIG, ''previous'');';
    cb_nextevent        = '[VI, ALLWIN, ALLSIG] = navigateevent         (VI, ALLWIN, ALLSIG, ''next'');';
    cb_event2sigevent   = '[VI, ALLWIN, ALLSIG] = pop_event2sigevent    (VI, ALLWIN, ALLSIG);';
    cb_ripplelab_ste    = '[VI, ALLWIN, ALLSIG] = pop_ripplelab_ste     (VI, ALLWIN, ALLSIG);';
    cb_ripplelab_sll    = '[VI, ALLWIN, ALLSIG] = pop_ripplelab_sll     (VI, ALLWIN, ALLSIG);';
    cb_ripplelab_hil    = '[VI, ALLWIN, ALLSIG] = pop_ripplelab_hil     (VI, ALLWIN, ALLSIG);';
    cb_ripplelab_mni    = '[VI, ALLWIN, ALLSIG] = pop_ripplelab_mni     (VI, ALLWIN, ALLSIG);';
    cb_spikedetect_wave = '[VI, ALLWIN, ALLSIG] = pop_spikedetect_wave  (VI, ALLWIN, ALLSIG);';
    cb_spikedetect_mteo = '[VI, ALLWIN, ALLSIG] = pop_spikedetect_mteo  (VI, ALLWIN, ALLSIG);';
    cb_artifactrej      = '[VI, ALLWIN, ALLSIG] = artifactrej_variationthresh(VI, ALLWIN, ALLSIG);';
    cb_cancel           = '[ALLWIN]             = buffernavigparams     (VI, ALLWIN, ALLSIG, ''cancel'');';
    cb_restore          = '[ALLWIN]             = buffernavigparams     (VI, ALLWIN, ALLSIG, ''restore'');';

    cb_cursor1          = '[VI, ALLWIN] = setcursor (VI, ALLWIN, ALLSIG, 1);';
    cb_cursor2          = '[VI, ALLWIN] = setcursor (VI, ALLWIN, ALLSIG, 2);';
    cb_cursor3          = '[VI, ALLWIN] = setcursor (VI, ALLWIN, ALLSIG, 3);';
    cb_capture          = 'capturefigure (VI, ALLWIN, ALLSIG, ''simple'');';
    cb_capturefull      = 'capturefigure (VI, ALLWIN, ALLSIG, ''full'');';
    
    cb_help             = 'web(fullfile(which(''micmac.m''),''..'',filesep,''doc'',filesep,''html'',filesep,''index.html''),''-browser'')';
    
    %- create menus
    sig_m       = uimenu (f,'Label','Signals');
    sig_load_m  = uimenu (sig_m,'Label','Load raw signal');
    uimenu (sig_load_m,'Label','EDF Files / Biosig','Callback',cb_loadrawsigedf,'Accelerator','O');
    uimenu (sig_load_m,'Label','NS5 Files / Blackrock','Callback',cb_loadrawsigns5);
    uimenu (sig_load_m,'Label','FIF Files','Callback',cb_loadrawsigfif);
    uimenu (sig_load_m,'Label','Event Signal','Callback',cb_loadeventsig,'Separator','on');
    sig_export_m= uimenu (sig_m,'Label','Export');
    uimenu (sig_export_m,'Label','Export Data','Callback',cb_exportdata);
    uimenu (sig_export_m,'Label','Export Data (EDF)','Callback',cb_exportdatatoedf);
    uimenu (sig_m,'Label','New montage','Callback',cb_newmontage,'Separator','on');
    uimenu (sig_m,'Label','Filter signal','Callback',cb_filtersig,'Accelerator','F','Separator','on'); 
    sig_op_m    = uimenu (sig_m,'Label','Operators');
    uimenu (sig_op_m,'Label','Threshold','Callback',cb_threshold);
    uimenu (sig_op_m,'Label','Extract Spikes','Callback',cb_extractspikes);
    uimenu (sig_op_m,'Label','k-TEO','Callback',cb_kteooperator);
    uimenu (sig_op_m,'Label','MTEO','Callback',cb_mteooperator);
    sig_clean_m = uimenu (sig_m,'Label', 'Clean signal');
    uimenu (sig_clean_m,'Label','Clean Line Noise','Callback',cb_cleanlinenoise);
    uimenu (sig_m,'Label','Mark as bad channels','Callback',cb_markbadchannels,'Separator', 'on');
    uimenu (sig_m,'Label','Set EEG channels','Callback',cb_seteegchannels);
    view_m  = uimenu (f,'Label','Views');
    uimenu (view_m,'Label','Add view','Callback',cb_addview,'Accelerator','V');
    win_m   = uimenu (f,'Label','Windows');
    uimenu (win_m,'Label','Add window','Callback',cb_addwindow);
    events_m = uimenu (f,'Label','Events');
    uimenu (events_m, 'Label', 'Event Panel','Callback',cb_seeevents,'Accelerator','E');
    events_add_m = uimenu(events_m, 'Label', 'Add');
    uimenu (events_add_m, 'Label', 'Add Event', 'Callback', cb_addevent,'Accelerator','A');
    uimenu (events_add_m, 'Label', 'Event Options', 'Callback', cb_addeventoptions);
    uimenu (events_m, 'Label', 'Frequency Estimation', 'Callback', cb_freqestimation);
    uimenu (events_m, 'Label', 'Hide Events (h)', 'Callback', cb_hideevents);
    uimenu (events_m, 'Label', 'Display/Hide Event Info', 'Callback', cb_dispeventinfo);
    events_import_m = uimenu (events_m, 'Label', 'Import', 'Separator', 'on');
    uimenu (events_import_m, 'Label', 'micMac events', 'Callback', cb_importmicmacevents);
    uimenu (events_import_m, 'Label', 'Anywave\Delphos events', 'Callback', cb_importanywaveevents);
    uimenu (events_import_m, 'Label', 'external events', 'Callback', cb_importextevents);
    uimenu (events_m, 'Label', 'Reject Events', 'Callback', cb_rejectevents, 'Separator', 'on');
    uimenu (events_m, 'Label', 'Previous Event (s)', 'Callback', cb_previousevent, 'Separator', 'on');
    uimenu (events_m, 'Label', 'Next Event (f)', 'Callback', cb_nextevent);
%     uimenu (events_m, 'Label', 'Convert to Event Signal', 'Callback', cb_event2sigevent);
    detect_m            = uimenu (f,'Label','Detectors');
    detect_hfo_m        = uimenu (detect_m,'Label','HFOs');
    detect_spikes_m     = uimenu (detect_m,'Label','Epileptic Spikes');
    detect_ripplelab_m  = uimenu (detect_hfo_m,'Label','Ripple Lab');
    uimenu (detect_ripplelab_m, 'Label', 'Short Time Energy (Staba)', 'Callback', cb_ripplelab_ste);
    uimenu (detect_ripplelab_m, 'Label', 'Short Line Length', 'Callback', cb_ripplelab_sll);
    uimenu (detect_ripplelab_m, 'Label', 'Hilbert', 'Callback', cb_ripplelab_hil);
    uimenu (detect_ripplelab_m, 'Label', 'MNI', 'Callback', cb_ripplelab_mni);
    uimenu (detect_m,           'Label', 'Artifact Rejection', 'Callback', cb_artifactrej);
    uimenu (detect_spikes_m,    'Label', 'Wavelet Detector', 'Callback', cb_spikedetect_wave);
    uimenu (detect_spikes_m,    'Label', 'MTEO Detector', 'Callback', cb_spikedetect_mteo);
    tools_m = uimenu (f,'Label','Tools');
    uimenu (tools_m, 'Label', 'Cancel',     'Callback', cb_cancel, 'Accelerator','Z');
    uimenu (tools_m, 'Label', 'Restore',    'Callback', cb_restore,'Accelerator','Y');
    uimenu (tools_m, 'Label', 'Cursor 1',   'Callback', cb_cursor1,'Accelerator','1','Separator','on');
    uimenu (tools_m, 'Label', 'Cursor 2',   'Callback', cb_cursor2,'Accelerator','2');
    uimenu (tools_m, 'Label', 'Cursor 3',   'Callback', cb_cursor3,'Accelerator','3');
    uimenu (tools_m, 'Label', 'Capture',    'Callback', cb_capture,'Accelerator','P','Separator','on');
    uimenu (tools_m, 'Label', 'Capture full','Callback',cb_capturefull);
    help_m  = uimenu(f,'Label','        Help');
    uimenu (help_m,  'Label', 'See Doc',    'Callback', cb_help);
end

  
%-----------------------------------               
%- Observation window time panel
cb_obstimetplus     = [
        'winnb = find(VI.figh==gcbf);',...
        'if isempty(ALLWIN(winnb).views); return; end;',...
        'ALLWIN(winnb).obstimet=ALLWIN(winnb).obstimet+',...
        num2str(vi_defaultval('obstimet_step')),';',...
        'for wn=ALLWIN(winnb).syncobstimetwin; ALLWIN(wn).obstimet=ALLWIN(1).obstimet;',...
        '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, find(VI.figh==wn));end;',...
        '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
        'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);clear wn;'];
cb_obstimetminus    = [
        'winnb = find(VI.figh==gcbf);',...    
        'if isempty(ALLWIN(winnb).views); return; end;',...
        'ALLWIN(winnb).obstimet=ALLWIN(winnb).obstimet-',...
        num2str(vi_defaultval('obstimet_step')),';',...
        'for wn=ALLWIN(winnb).syncobstimetwin; ALLWIN(wn).obstimet=ALLWIN(1).obstimet;',...
        '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, find(VI.figh==wn));end;',...
        '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
        'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);clear wn;'];
cb_editobstimet      = [
        'winnb = find(VI.figh==gcbf);',...    
        'if isempty(ALLWIN(winnb).views); return; end;',...
        'newval = str2double(get(findobj(gcbf,''tag'',''obswintedit''),''String''));',...
        'if isnan(newval); return; else; ALLWIN(winnb).obstimet=newval; end;',...
        'for wn=ALLWIN(winnb).syncobstimetwin; ALLWIN(wn).obstimet=ALLWIN(1).obstimet;',...
        '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, find(VI.figh==wn));end;',...
        '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
        'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);',...
        'clear newval wn;',...
        ];
    
obswint_p = uipanel(f,'Title','','Units','pixels','Position',[0.15*figpos(3),5,0.2*figpos(3),40],'tag','obswintp');
uicontrol (obswint_p,'Style','text','String','Win. time','Units','normalized','Position',[0,0.2,0.45,0.6],'fontsize',vi_graphics('fontsize_base'));
uicontrol (obswint_p,'Style','pushbutton','String','-','Units','normalized','Position',[0.5,0.2,0.15,0.6],...
        'Callback',cb_obstimetminus);
uicontrol (obswint_p,'Style','edit','String','','Units','normalized','Position',[0.67,0.2,0.15,0.6],...
        'Callback',cb_editobstimet,'tag','obswintedit');
uicontrol (obswint_p,'Style','pushbutton','String','+','Units','normalized','Position',[0.84,0.2,0.15,0.6],...
        'Callback',cb_obstimetplus);
    
%-----------------------------------    
%- Move in time panel

cb_fastforward  = [
            'winnb  = find(VI.figh==gcbf);',...
            'if isempty(ALLWIN(winnb).views); return; end;',...
            'ALLWIN(winnb).ctimet=ALLWIN(winnb).ctimet+ALLWIN(winnb).obstimet;',...
            'for wn=ALLWIN(winnb).syncctimetwin; ALLWIN(wn).ctimet=ALLWIN(1).ctimet;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, wn);',...
            'end;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
            'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'];
cb_forward      = [
            'winnb  = find(VI.figh==gcbf);',...
            'if isempty(ALLWIN(winnb).views); return; end;',...
            'ALLWIN(winnb).ctimet=ALLWIN(winnb).ctimet+',num2str(vi_defaultval('ctimet_step')),...
            '*ALLWIN(winnb).obstimet;',...
            'for wn=ALLWIN(winnb).syncctimetwin; ALLWIN(wn).ctimet=ALLWIN(1).ctimet;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, wn);end;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
            'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'];
cb_backward     = [
            'winnb  = find(VI.figh==gcbf);',...   
            'if isempty(ALLWIN(winnb).views); return; end;',...
            'ALLWIN(winnb).ctimet=ALLWIN(winnb).ctimet-',num2str(vi_defaultval('ctimet_step')),...
            '*ALLWIN(winnb).obstimet;',...
            'for wn=ALLWIN(winnb).syncctimetwin; ALLWIN(wn).ctimet=ALLWIN(1).ctimet;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, wn);end;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
            'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'];
cb_fastbackward = [
            'winnb  = find(VI.figh==gcbf);',...   
            'if isempty(ALLWIN(winnb).views); return; end;',...
            'ALLWIN(winnb).ctimet=ALLWIN(winnb).ctimet-ALLWIN(winnb).obstimet;',...
            'for wn=ALLWIN(winnb).syncctimetwin; ALLWIN(wn).ctimet=ALLWIN(1).ctimet;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, wn);end;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
             'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'];
cb_editctimet   = [
            'winnb  = find(VI.figh==gcbf);',...   
            'if isempty(ALLWIN(winnb).views); return; end;',...
            'newctimet = str2double(get(findobj(winnb,''tag'',''ctimetedit''),''String''));',...
            'if isnan(newctimet); return; else; ALLWIN(winnb).ctimet=newctimet; end;',...
            'for wn=ALLWIN(winnb).syncctimetwin; ALLWIN(wn).ctimet=ALLWIN(1).ctimet;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, wn);end;',...
            '[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG);',...
            'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'];


mit_p   = uipanel(f,'Title','','Units','pixels','Position',[0.4*figpos(3),5,0.2*figpos(3),40],'tag','mitp');
uicontrol (mit_p,'Style','edit','Units','normalized','Position',[0.42,0.2,0.16,0.6],'tag','ctimetedit',...
        'Callback',cb_editctimet);
uicontrol (mit_p,'Style','pushbutton','Units','normalized','String','<<','Position',[0.05,0.2,0.15,0.6],...
        'Callback',cb_fastbackward);
uicontrol (mit_p,'Style','pushbutton','Units','normalized','String','<','Position', [0.25,0.2,0.1,0.6],...
        'Callback',cb_backward);
uicontrol (mit_p,'Style','pushbutton','Units','normalized','String','>','Position', [0.65,0.2,0.1,0.6],...
        'Callback',cb_forward);
uicontrol (mit_p,'Style','pushbutton','Units','normalized','String','>>','Position',[0.8,0.2,0.15,0.6],...
        'Callback',cb_fastforward);

    
%-----------------------------------    
%- Zoom buttons
cb_zoomt = '[ALLWIN] = zoomonsel (VI,ALLWIN,ALLSIG,''t'');';
cb_zoomc = [
    'winnb  = find(VI.figh==gcbf);',...
    'if ALLWIN(winnb).visumode==1;',...
    '[ALLWIN] = zoomonsel (VI,ALLWIN,ALLSIG,''c'');',...
    'end;',...
    ];
cb_zoomtc = [
    'winnb  = find(VI.figh==gcbf);',...
    'if ALLWIN(winnb).visumode==1;',...
    '[ALLWIN] = zoomonsel (VI,ALLWIN,ALLSIG,''t-c'');',...
    'end;',...
    ];

zoom_p = uipanel(f,'Title','Zoom','Units','pixels','Position',[0.6*figpos(3)+70,5,0.08*figpos(3),40],...
    'tag','zoomp','fontsize',8);
uicontrol (zoom_p,'style','pushbutton','string','t','Units','normalized','Position',[0.0625,0.1,0.25,0.8],...
    'fontsize',8,'Callback',cb_zoomt);
uicontrol (zoom_p,'style','pushbutton','string','c','Units','normalized','Position',[0.3750,0.1,0.25,0.8],...
    'fontsize',8,'Callback',cb_zoomc,'tag','zoomc');
uicontrol (zoom_p,'style','pushbutton','string','t-c','Units','normalized','Position',[0.6875,0.1,0.25,0.8],...
    'fontsize',8,'Callback',cb_zoomtc,'tag','zoomtc');


  
    
%- Synchronisation checkboxes
cb_syncobstimet = ['val = get(findobj(''parent'',gcbf,''tag'',''syncobstimetcb''),''Value'');'...
                   'ALLWIN   = settimesync (VI, ALLWIN, ALLSIG, find(VI.figh==gcbf), ''obstimet'', val);',...
                   'ALLWIN   = redrawwin(VI,ALLWIN,ALLSIG);'];
cb_syncctimet   = ['val = get(findobj(''parent'',gcbf,''tag'',''syncctimetcb''),''Value'');'...
                   'ALLWIN = settimesync (VI, ALLWIN, ALLSIG, find(VI.figh==gcbf), ''ctimet'', val);',...
                   'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'];
cb_syncchansel  = [
    'val    = get(findobj(''parent'',gcbf,''tag'',''syncchancb''),''Value'');',...
    'winnb  = find(VI.figh==gcbf);',...
    'ALLWIN(winnb).chansel = ALLWIN(1).chansel;',...
    'if val; ALLWIN(1).syncchanselwin(end+1)=winnb;else;',...
    'ALLWIN(1).syncchanselwin(ALLWIN(1).syncchanselwin==winnb)=[];',...
    'ALLWIN(winnb).chansel = get(findobj(''parent'',gcbf,''tag'',''chansellb''),''Value'');'...
    'end;'...
    'enableval = fastif(val==0,''on'',''off'');',...
    'set (findobj(gcbf,''tag'',''chansellb''),''enable'',enableval);',...
    'set (findobj(gcbf,''tag'',''chanselsel''),''enable'',enableval);',...
    'zoom_p      = findobj(''parent'',gcbf,''tag'',''zoomp'');',...
    'set (findall (zoom_p,''string'',''t-c''), ''enable'', fastif(val,''off'',''on''));',....
    'set (findall (zoom_p,''string'',''c''), ''enable'', fastif(val,''off'',''on''));',...
    'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);',...
    'clear val winnb enableval zoom_p;',...
    ];


if ~ismain
    uicontrol (f,'Style','text','String','Sync','Fontsize',7,'Position',[0.6*figpos(3)+5,27,25,15],...
        'BackgroundColor',vi_graphics('backgroundcolor'),'tag','syncctimettext');
    uicontrol (f,'Style','checkbox','Position',[0.6*figpos(3)+10,15,15,15],...
        'tag','syncctimetcb','Callback',cb_syncctimet);
    uicontrol (f,'Style','text','String','Sync','Fontsize',7,'Position',[0.35*figpos(3)+5,27,25,15],...
        'BackgroundColor',vi_graphics('backgroundcolor'),'tag','syncobstimettext');
    uicontrol (f,'Style','checkbox','Position',[0.35*figpos(3)+10,15,15,15],...
        'tag','syncobstimetcb','Callback',cb_syncobstimet);
    uicontrol (f,'Style','checkbox','Units','pixels','Position',[5,3*figpos(4)/4+95,15,15],...
        'tag','syncchancb','callback',cb_syncchansel);
end

%- Information area
info_c = uicontrol (f,'Style','text','Units','normalized','Position',[0.8,0.01,0.15,0.03],'tag','textinfo');

%- Channel sel area
cb_chanselsel = [
    'winnb  = find(VI.figh==gcbf);',...
    'if isempty(ALLWIN(winnb).views); return; end;',...
    'chansel = get(findobj(gcbf,''tag'',''chansellb''),''Value'');',...
    'ALLWIN(winnb).chansel = chansel;',...
    'ALLWIN = buffernavigparams (VI, ALLWIN, ALLSIG, ''buffer'',winnb);',...
    'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);',...
    'if winnb==1;',...
    'for winnb=ALLWIN(1).syncchanselwin;',...
    '   ALLWIN(winnb).chansel = getcorrchannels(VI,ALLWIN,ALLSIG,winnb,1);',...
    '   ALLWIN = redrawwin(VI,ALLWIN,ALLSIG,winnb); end;',...
    'end;',...
    ];
    
cb_chanselenter = [
    'if uint8(get(gcbf,''CurrentCharacter''))==13;',...
    cb_chanselsel,...
    'end;',...
    ];
uicontrol (f,'Style','text','String','Channels','Units','pixels','Position',[5,3*figpos(4)/4+5,80,15],...
    'BackgroundColor',vi_graphics('backgroundcolor'),'tag','chanseltext','fontsize',vi_graphics('fontsize_base'));
uicontrol (f,'Style','listbox','Units','pixels','Position',[5,figpos(4)/4,100,figpos(4)/2],...
    'max',100, 'min',1,'tag','chansellb','fontsize',vi_graphics('fontsize_base'),...
    'KeyPressFcn',cb_chanselenter);
uicontrol (f','Style','pushbutton','String','Select','Units','pixels','Position',[10,figpos(4)/4-30,80,25],'tag','chanselsel',...
    'Callback',cb_chanselsel,'fontsize',vi_graphics('fontsize_base'));


%- Gain panel
cb_gainplus     = [
    'winnb = find(VI.figh==gcbf);',...
    'if isempty(ALLWIN(winnb).views) || isempty(ALLWIN(winnb).axlist); return; end;',...
    'axfocus = ALLWIN(winnb).axfocus;',...
    'if isempty(axfocus); axfocus=gca; elseif isempty(find(ALLWIN(winnb).axlist==axfocus)); axfocus = gca; end;',...
    'visumode= ALLWIN(winnb).visumode;',...
    'viewind = getfocusedviewpos(ALLWIN(winnb),axfocus);',...
    'gainVal = min(vi_defaultval(''gain_max''),ALLWIN(winnb).views(viewind).gain(visumode)+vi_defaultval(''gain_step''));',...
    'ALLWIN(winnb).views(viewind).gain(visumode) = gainVal;',...
    '[ampscale,ampscalestr] = getampscalefromgain(gainVal, visumode, axfocus);',...
    'ALLWIN(winnb).views(viewind).scale(visumode) = ampscale;',...
    'set(findobj(winnb,''tag'',''gainedit''),''String'',ampscalestr);',...
    'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'
    ];
cb_gainminus    = [
    'winnb = find(VI.figh==gcbf);',...
    'if isempty(ALLWIN(winnb).views) || isempty(ALLWIN(winnb).axlist); return; end;',...
    'axfocus = ALLWIN(winnb).axfocus;',...
    'if isempty(axfocus); axfocus=gca; elseif isempty(find(ALLWIN(winnb).axlist==axfocus)); axfocus = gca; end;',...
    'visumode= ALLWIN(winnb).visumode;',...
    'viewind = getfocusedviewpos(ALLWIN(winnb),axfocus);',... 
    'gainVal = max(vi_defaultval(''gain_min''),ALLWIN(winnb).views(viewind).gain(visumode)-vi_defaultval(''gain_step''));',...
    'ALLWIN(winnb).views(viewind).gain(visumode) = gainVal;',...
    '[ampscale,ampscalestr] = getampscalefromgain(gainVal, visumode, axfocus);',...
    'ALLWIN(winnb).views(viewind).scale(visumode) = ampscale;',...
    'set(findobj(winnb,''tag'',''gainedit''),''String'',ampscalestr);',...
    'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);'
    ];
cb_editgain     = [
    'winnb = find(VI.figh==gcbf);',...
    'if isempty(ALLWIN(winnb).views) || isempty(ALLWIN(winnb).axlist); return; end;',...
    'ampscale = str2double(get(findobj(winnb,''tag'',''gainedit''),''String''));',...
    'if isnan(ampscale); return; end;',...
    'axfocus = ALLWIN(winnb).axfocus;',...
    'if isempty(axfocus); axfocus=gca; elseif isempty(find(ALLWIN(winnb).axlist==axfocus)); axfocus = gca; end;',...
    'visumode= ALLWIN(winnb).visumode;',...
    'viewind = getfocusedviewpos(ALLWIN(winnb),axfocus);',...
    'gainVal = getgainfromampscale(ampscale, visumode);',...
    'gainVal = median([vi_defaultval(''gain_min''),gainVal,vi_defaultval(''gain_max'')]);',...
    'ALLWIN(winnb).views(viewind).gain(visumode) = gainVal;',...
    'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);',...
    '[ampscale,ampscalestr] = getampscalefromgain(gainVal, visumode, axfocus);',...
    'ALLWIN(winnb).views(viewind).scale(visumode) = ampscale;',...
    'set(findobj(winnb,''tag'',''gainedit''),''String'',ampscalestr);',...
    ];


gain_p = uipanel(f,'Title','Gain','Units','pixels','Position',[5,3*figpos(4)/4+100,100,90],'tag','gainp');
uicontrol (gain_p,'Style','pushbutton','String','-','Units','normalized','Position',[0.1,0.55,0.35,0.40],...
    'Callback',cb_gainminus);
uicontrol (gain_p,'Style','pushbutton','String','+','Units','normalized','Position',[0.55,0.55,0.35,0.40],...
    'Callback',cb_gainplus);
uicontrol (gain_p,'Style','edit','String','','Units','normalized','Position',[0.1,0.1,0.5,0.35],...
    'Callback',cb_editgain,'tag','gainedit');
uicontrol (gain_p,'Style','text','String','uV/cm','Units','normalized','Position',[0.65,0.1,0.33,0.35],...
    'fontsize',8);


%- Visualization mode
cb_visumodechanged= ['selobj = get(findobj(''parent'',gcbf,''tag'',''visumodebg''),''SelectedObject'');',...
    'winnb = find(VI.figh==gcbf);visutag=get(selobj,''tag'');',...
    'switch(visutag);',...
    'case ''stacked'';ALLWIN(winnb).visumode=1;',...
    'set(findobj(gcbf,''tag'',''zoomc''),''enable'',''on'');',...
    'set(findobj(gcbf,''tag'',''zoomtc''),''enable'',''on'');',...
    'case ''spaced''; ALLWIN(winnb).visumode=2;',...
    'set(findobj(gcbf,''tag'',''zoomc''),''enable'',''off'');',...
    'set(findobj(gcbf,''tag'',''zoomtc''),''enable'',''off'');',...
    'end;',...
    'ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);',...
    'if ~isempty(ALLWIN(winnb).views);',...
    'gainVal = ALLWIN(winnb).views(1).gain(ALLWIN(winnb).visumode);',...
    '[~,ampscalestr] = getampscalefromgain(gainVal, ALLWIN(winnb).visumode, ALLWIN(winnb).axlist(1));',...
    'set(findobj(winnb,''tag'',''gainedit''),''String'',ampscalestr);',...
    'else; ALLWIN(winnb).axfocus = []; end;',...
    'if ~isempty(ALLWIN(winnb).views);ALLWIN(winnb).axfocus = ALLWIN(winnb).axlist(1);end;',...
    'ALLWIN(winnb).viewfocus = getfocusedviewpos(ALLWIN(winnb));',...
    ];

visumode_bg = uibuttongroup('Units','pixels','Position',[5,0.85*figpos(4),100,40],...
    'tag','visumodebg','BackgroundColor',vi_graphics('backgroundcolor'),...
    'SelectionChangeFcn',cb_visumodechanged);

uicontrol (visumode_bg,'Style','togglebutton','String','1','Units','normalized',...
    'Position',[0.1,0.1,0.35,0.8],'Fontsize',vi_graphics('fontsize_base'),'tag','stacked');
uicontrol (visumode_bg,'Style','togglebutton','String','2','Units','normalized',...
    'Position',[0.55,0.1,0.35,0.8],'Fontsize',vi_graphics('fontsize_base'),'tag','spaced');


if strcmpi(vi_defaultval('colorscheme'),'dark')
    %- panels
    set(findobj(f,'type','uipanel'),'BackgroundColor',vi_graphics('panelbackcolor'),'HighlightColor',vi_graphics('edgecolor'),'ShadowColor',vi_graphics('edgecolorshadow'),'ForegroundColor',vi_graphics('textcolor'));
    set(findobj(f,'style','pushbutton'),'BackgroundColor',vi_graphics('buttonbackcolor'),'ForegroundColor',vi_graphics('buttonforecolor'));
    set(visumode_bg,'backgroundColor',vi_graphics('panelbackcolor'),'ForegroundColor',vi_graphics('edgecolor'),'shadowColor',vi_graphics('edgecolorshadow'),'highlightColor',vi_graphics('edgecolor'));
    %- text
    set(findobj(f,'style','text'),'BackgroundColor',vi_graphics('backgroundcolor'),'ForegroundColor',vi_graphics('textcolor'));
    %- info area
    set(info_c,'BackgroundColor',vi_graphics('backgroundcolor'),'foregroundColor',vi_graphics('textcolor'));
    %- chansel listbox
    set(findobj('tag','chansellb'),'backgroundcolor',vi_graphics('panelbackcolor'),'foregroundColor',vi_graphics('textcolor'));
end
    
end


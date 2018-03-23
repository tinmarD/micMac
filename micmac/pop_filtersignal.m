function [VI, ALLWIN, ALLSIG ] = pop_filtersignal (VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG ] = POP_FILTERSIGNAL (VI, ALLWIN, ALLSIG)
%   Popup window for filtering continuous signals
%   Filters can be High-Pass, Low-Pass, Band-Pass or Band-Stop
%   FIR, Butterworth, Chebyshev I and II and Elliptic algorithms are
%   available
%
% See also computefiltercoeff
    

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous');
if isempty(SigCont)
    msgbox ('You need to load a signal first');
    return;
end

filtertypefreq  = vi_defaultval('filter_type_freq');
filtertypename  = vi_defaultval('filter_type_name');

cb_filtertypefreq = [   
    'switch(get(findobj(''parent'',gcbf,''tag'',''typefreq''), ''value''));',...
    'case 1;',...
        'set(findobj(''parent'',gcbf,''tag'',''lowcutoff''),   ''enable'',''off'');',...
        'set(findobj(''parent'',gcbf,''tag'',''highcutoff''),  ''enable'',''on'');',...
    'case 2;',...
        'set(findobj(''parent'',gcbf,''tag'',''lowcutoff''),   ''enable'',''on'');',...
        'set(findobj(''parent'',gcbf,''tag'',''highcutoff''),  ''enable'',''off'');',...
    'case 3;',...
        'set(findobj(''parent'',gcbf,''tag'',''lowcutoff''),   ''enable'',''on'');',...
        'set(findobj(''parent'',gcbf,''tag'',''highcutoff''),  ''enable'',''on'');',...
    'case 4;',...
        'set(findobj(''parent'',gcbf,''tag'',''lowcutoff''),   ''enable'',''on'');',...
        'set(findobj(''parent'',gcbf,''tag'',''highcutoff''),  ''enable'',''on'');',...       
    'end;'];

cb_filtertypename = [   
    'value      = get(findobj(''parent'',gcbf,''tag'',''typename''), ''value'');',...
    'filtnames  = get(findobj(''parent'',gcbf,''tag'',''typename''), ''string'');',...
    'fparam1    = findobj(gcbf,''tag'',''fparam1'');',...
    'fparam2    = findobj(gcbf,''tag'',''fparam2'');',...
    'fparam1val = findobj(gcbf,''tag'',''fparam1val'');',...
    'fparam2val = findobj(gcbf,''tag'',''fparam2val'');',...
    'switch (filtnames{value})',...
    'case ''FIR'';',...
        'set(fparam1,''visible'',''off'');set(fparam1val,''visible'',''off'');',...
        'set(fparam2,''visible'',''off'');set(fparam2val,''visible'',''off'');',...
    'case ''Butterworth'';',...
        'set(fparam1,''visible'',''off'');set(fparam1val,''visible'',''off'');',...
        'set(fparam2,''visible'',''off'');set(fparam2val,''visible'',''off'');',...
    'case ''Chebyshev Type I'';',...
        'set(fparam1,''visible'',''on'',''string'',''Bandpass Attenuation (dB)'');',...
        'set(fparam1val,''visible'',''on'',''string'',''0.5'');',...
        'set(fparam2,''visible'',''off'');set(fparam2val,''visible'',''off'');',...
    'case ''Chebyshev Type II'';',...
        'set(fparam1,''visible'',''on'',''string'',''Bandstop Attenuation (dB)'');',...
        'set(fparam1val,''visible'',''on'',''string'',''60'');',...
        'set(fparam2,''visible'',''off'');set(fparam2val,''visible'',''off'');',...     
    'case ''Elliptic'';',...
        'set(fparam1,''visible'',''on'',''string'',''Bandpass Attenuation (dB)'');',...
        'set(fparam1val,''visible'',''on'',''string'',''0.5'');',...
        'set(fparam2,''visible'',''on'',''string'',''Bandstop Attenuation (dB)'');',...
        'set(fparam2val,''visible'',''on'',''string'',''60'');',...
    'end;'];
        
cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

cb_freqresponse = [
    'SigCont     = getsignal(ALLSIG,''type'',''continuous'');',...
    'sigind      = get(findobj(gcbf,''tag'',''rawsigs''),''value'');',...
    'sigsrate    = SigCont(sigind).srate;',...
    'ftypefreqind= get(findobj(gcbf,''tag'',''typefreq''),''value'');',...
    'ftypenameind= get(findobj(gcbf,''tag'',''typename''),''value'');',...
    'forder      = str2double(get(findobj(gcbf,''tag'',''filtorder''),''string''));',...
    'fclow       = str2double(get(findobj(gcbf,''tag'',''lowcutoff''),''string''));',...
    'fchigh      = str2double(get(findobj(gcbf,''tag'',''highcutoff''),''string''));',...
    'fparam1val  = str2double(get(findobj(gcbf,''tag'',''fparam1val''),''string''));',...
    'fparam2val  = str2double(get(findobj(gcbf,''tag'',''fparam2val''),''string''));',...
    'if ftypenameind==1;',... 
        '[b,a]   = computefiltercoeff (sigsrate,ftypefreqind,ftypenameind,forder,fclow,fchigh,fparam1val,fparam2val);',...
        'if ~isempty(b) && ~isempty(a);',...
            'figure (''DockControls'',''off'',''MenuBar'',''none'',''Name'',''Filter Frequency Response'',''NumberTitle'',''off'',''tag'',''freqresponse'');',...
            'freqz(b,a,2048,sigsrate);',...
        'end;',...
    'else;',...
        'if verLessThan(''matlab'',''8.1'');',...
            '[b,a,~,sigdesc] = computefiltercoeff (sigsrate, ftypefreqind, ftypenameind, forder, fclow, fchigh, fparam1val, fparam2val);',...
            'if ~isempty(b) && ~isempty(a);',...
                'fvtool(b,a);',...
            'end;',...
        'else;',...
            '[z,p,k] = computefiltercoeff (sigsrate,ftypefreqind,ftypenameind,forder,fclow,fchigh,fparam1val,fparam2val);',...
            'if ~isempty(z) && ~isempty(p) && ~isempty(k);',...
                'sos 	 = zp2sos(z,p,k);',...
                'fvtool(sos);',...
            'end;',...
        'end;',...
    'end;',...
];

windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;
for w=1:VI.nwin; windowsnb{w}=w; end;

geometry = {[1,1],[1,1],[1,1],[1,0.5,0.5],[1,1],[1,1],[1,1],[1,1],1,[1,1],[1,1,1,1]};
uilist   = {...
    {'Style','text','String','Raw signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','rawsigs'},...
    {'Style','text','String','Filter type :'},...
    {'Style','popupmenu','String',filtertypefreq,'Callback',cb_filtertypefreq,'tag','typefreq'},...
    {},{'Style','popupmenu','String',filtertypename,'tag','typename','value',2,'callback',cb_filtertypename},...
    {'Style','text','String','Cut-off frequency (Hz):'},...
    {'Style','edit','String','low','tag','lowcutoff','enable','off'},...
    {'Style','edit','String','high','tag','highcutoff'},...
    {'Style','text','String','Order :'},...
    {'Style','edit','String','8','tag','filtorder'},...
    {'Style','text','String',' ','visible','off','tag','fparam1'},...
    {'Style','edit','String','','visible','off','tag','fparam1val'},...
    {'Style','text','String',' ','visible','off','tag','fparam2'},...
    {'Style','edit','String','','visible','off','tag','fparam2val'},...
    {},{'Style','pushbutton','String','Frequency Response','Callback',cb_freqresponse},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'},...
};

results = inputgui (geometry, uilist, 'title', 'Filter parameters');

if ~isempty(results)
    %- Check parameters
    sigind      = results{1};
    ftypefreqind= results{2};
    ftypenameind= results{3};
    sigdescin   = SigCont(sigind).desc;
    sigsrate    = SigCont(sigind).srate;
    fclow       = str2double(results{4});
    fchigh      = str2double(results{5});
    forder      = str2double(results{6});
    fparam1val  = str2double(results{7});
    fparam2val  = str2double(results{8});
    
    if ftypenameind==1
        if rem(forder,2)==1; forder=forder+1; end; % Make the filter order even (to have an integer delay)
        [b,a,~,sigdesc] = computefiltercoeff (sigsrate, ftypefreqind, ftypenameind, forder, fclow, fchigh, fparam1val, fparam2val, sigdescin);
        if isempty(b) || isempty(a); return; end;
    else
        if verLessThan('matlab','8.1')
            [b,a,~,sigdesc] = computefiltercoeff (sigsrate, ftypefreqind, ftypenameind, forder, fclow, fchigh, fparam1val, fparam2val, sigdescin);
        else
            [z,p,k,sigdesc] = computefiltercoeff (sigsrate, ftypefreqind, ftypenameind, forder, fclow, fchigh, fparam1val, fparam2val, sigdescin);
            if isempty(z) || isempty(p) || isempty(k); return; end;
            [sos,g]         = zp2sos (z,p,k);
        end
    end

    Sig         = SigCont(sigind);
    sigdesc     = makeuniquesigdesc (SigCont, sigdesc);
        
    % filter the data 
    datafilt    = zeros(Sig.nchan,Sig.npnts);
    h_wb = waitbar(0,'Filtering Data','color',vi_graphics('waitbarbackcolor'),'visible','off','name','micMac');
    set(get(findobj(h_wb,'type','axes'),'title'),'color',vi_graphics('textcolor')); set(h_wb,'visible','on');

    nchaneeg    = Sig.nchaneeg;
    dispinfo ('Filtering...',1);
    eegchannelpos   = nonzeros(Sig.eegchannelind.*(1:Sig.nchan));
    if ftypenameind==1 % FIR filter
        for i=1:nchaneeg
            datafilt(eegchannelpos(i),:) = filter(b,a,Sig.data(eegchannelpos(i),:));
            datafilt(eegchannelpos(i),:) = [datafilt(eegchannelpos(i),forder/2:end),zeros(1,forder/2-1)];
            try waitbar(i/nchaneeg,h_wb); catch; end;
        end
    else % IIR filter
        if verLessThan('matlab','8.1')
            for i=1:nchaneeg
                datafilt(eegchannelpos(i),:) = filtfilt(b,a,Sig.data(eegchannelpos(i),:));
                try waitbar(i/nchaneeg,h_wb); catch; end;
            end
        else
            for i=1:nchaneeg
                datafilt(eegchannelpos(i),:) = filtfilt(sos,g,Sig.data(eegchannelpos(i),:));
                try waitbar(i/nchaneeg,h_wb); catch; end;
            end
        end
    end
    try close(h_wb); catch; end;
    dispinfo ('');
    % For the non eeg channels, copy the original data
    datafilt (~Sig.eegchannelind,:) = Sig.data(~Sig.eegchannelind,:);

    % Add the filtered signal
    [VI, ALLWIN, ALLSIG, sigid] = addsignal (VI, ALLWIN, ALLSIG, datafilt, Sig.channames, ...
        sigsrate, 'continuous', Sig.filename, Sig.filepath, Sig.montage, ...
        sigdesc, 0, Sig.id, Sig.badchannelpos);
    
    % Add a view if asked 
    if results{9}
        [VI, ALLWIN, ALLSIG] = addview (VI, ALLWIN, ALLSIG, results{10},sigid,'t',str2double(results{11}));
    end
    
end

% Close the frequency response windows
for fh=findobj('tag','freqresponse')
    delete(fh);
end

end


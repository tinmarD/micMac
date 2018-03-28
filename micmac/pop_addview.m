function [ VI, ALLWIN, ALLSIG ] = pop_addview( VI, ALLWIN, ALLSIG)
% [VI,ALLWIN,ALLSIG] = pop_addview (VI,ALLWIN,ALLSIG)


[~,~,~,~,sigdesc]   = getsignal (ALLSIG);
if isempty(sigdesc)
    msgbox ('You need to load a signal before adding a view');
    return;
end
fmaxstr     = num2str(ALLSIG(1).srate/2);
domains     = vi_defaultval('visu_domains');
domainsshort= vi_defaultval('visu_domains_short');

if strcmp(ALLSIG(1).type,'eventSig')
    domainsInit = {'time'};
else
	domainsInit = domains;
end
windowsnb   = cell(1,VI.nwin);
for w=1:VI.nwin; windowsnb{w}=w; end;


position = length(ALLWIN(end).views)+1;

cb_sigchanged = [
    'sigpos = get(findobj(gcbf,''tag'',''sigsel''),''value'');',...
    'Sig    = ALLSIG(sigpos);',...
    'if strcmp(Sig.type,''continuous'');',...
    'set(findobj(gcbf,''tag'',''domainsel''),''string'',vi_defaultval(''visu_domains''));',...
    'set(findobj(gcbf,''tag'',''fmax''),''string'',num2str(Sig.srate/2));',...
    'elseif strcmp(Sig.type,''eventSig'');',...
    'set(findobj(gcbf,''tag'',''domainsel''),''string'',{''time''},''value'',1);',...
    'set(findobj(gcbf,''tag'',''wnamet''),''visible'',''off''); set(findobj(gcbf,''tag'',''wname''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''fmint''),''visible'',''off'');  set(findobj(gcbf,''tag'',''fmin''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''fmaxt''),''visible'',''off'');  set(findobj(gcbf,''tag'',''fmax''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''fstept''),''visible'',''off''); set(findobj(gcbf,''tag'',''fstep''),''visible'',''off'');',...
    'end;'
    ];

cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                 
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

cb_logcbcheck = [
    'domainstr  = get(findobj(gcbf,''tag'',''domainsel''),''String'');',...
    'value      = get(findobj(gcbf,''tag'',''domainsel''),''value'');',...
    'if strcmp(domainstr{value},''time-frequency'') || strcmp(domainstr{value},''phase'');',...
    'if get(findobj(gcbf,''tag'',''logcb''),''Value'');',...
    'set(findobj(gcbf,''tag'',''fstept''),''String'',''num. freqs'');',...
    'else;',...
    'set(findobj(gcbf,''tag'',''fstept''),''String'',''freq step'');',...
    'end;end;'];

cb_wavnamechanged = [
    'wavnames   = get(findobj(gcbf,''tag'',''wname''),''String'');',...
    'value      = get(findobj(gcbf,''tag'',''wname''),''value'');',...
    'wavnamesel = wavnames{value};',...
    'if strcmp(wavnamesel,''cmor-var'');visstr=''on'';else;visstr=''off'';end;',...
    'set(findobj(gcbf,''tag'',''cmint''),''visible'',visstr);',...
    'set(findobj(gcbf,''tag'',''cmin''),''visible'',visstr);',...
    'set(findobj(gcbf,''tag'',''cmaxt''),''visible'',visstr);',...
    'set(findobj(gcbf,''tag'',''cmax''),''visible'',visstr);'];


cb_domainchanged = [
    'domainstr  = get(findobj(gcbf,''tag'',''domainsel''),''String'');',...
    'value      = get(findobj(gcbf,''tag'',''domainsel''),''value'');',...
    'switch domainstr{value};',...
    'case ''time'';',... 
    'set(findobj(gcbf,''tag'',''wnamet''),''visible'',''off''); set(findobj(gcbf,''tag'',''wname''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''fmint''),''visible'',''off'');  set(findobj(gcbf,''tag'',''fmin''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''fmaxt''),''visible'',''off'');  set(findobj(gcbf,''tag'',''fmax''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''fstept''),''visible'',''off''); set(findobj(gcbf,''tag'',''fstep''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''logt''),''visible'',''off''); set(findobj(gcbf,''tag'',''logcb''),''visible'',''off'');',...
    'case ''time-frequency'';',... 
    'set(findobj(gcbf,''tag'',''wnamet''),''visible'',''on'',''string'',''wavelet name'');',...  
    'set(findobj(gcbf,''tag'',''wname''),''visible'',''on'',''string'',vi_defaultval(''wavelet_names''),''value'',1);',...
    'set(findobj(gcbf,''tag'',''fmint''),''visible'',''on'');   set(findobj(gcbf,''tag'',''fmin''),''visible'',''on'',''string'',''2'');',...
    'set(findobj(gcbf,''tag'',''fmaxt''),''visible'',''on'');   set(findobj(gcbf,''tag'',''fmax''),''visible'',''on'');',...
    'set(findobj(gcbf,''tag'',''fstept''),''visible'',''on'',''string'',''freq step'');  set(findobj(gcbf,''tag'',''fstep''),''visible'',''on'',''string'',''5'');',...
    'set(findobj(gcbf,''tag'',''logt''),''visible'',''on''); set(findobj(gcbf,''tag'',''logcb''),''visible'',''on'',''value'',0);',...
    'set(findobj(gcbf,''tag'',''cmint''),''visible'',''off''); set(findobj(gcbf,''tag'',''cmin''),''visible'',''off'');',...
    'set(findobj(gcbf,''tag'',''cmaxt''),''visible'',''off''); set(findobj(gcbf,''tag'',''cmax''),''visible'',''off'');',...
    'case ''power spectrum'';',...
    'set(findobj(gcbf,''tag'',''wnamet''),''visible'',''on'',''string'',''method'');',... 
    'set(findobj(gcbf,''tag'',''wname''),''visible'',''on'',''string'',vi_defaultval(''psd_methods''));',...
    'set(findobj(gcbf,''tag'',''fmint''),''visible'',''on'');   set(findobj(gcbf,''tag'',''fmin''),''visible'',''on'',''string'',''0'');',...
    'set(findobj(gcbf,''tag'',''fmaxt''),''visible'',''on'');   set(findobj(gcbf,''tag'',''fmax''),''visible'',''on'');',...
    'set(findobj(gcbf,''tag'',''fstept''),''visible'',''on'',''string'',''nfft''); set(findobj(gcbf,''tag'',''fstep''),''visible'',''on'',''string'',''16384'');',...  
    'set(findobj(gcbf,''tag'',''logt''),''visible'',''on''); set(findobj(gcbf,''tag'',''logcb''),''visible'',''on'',''value'',0);',...
    'case ''phase'';',...
    'set(findobj(gcbf,''tag'',''wnamet''),''visible'',''on'',''string'',''wavelet name'');',...   
    'set(findobj(gcbf,''tag'',''wname''),''visible'',''on'',''string'',vi_defaultval(''wavelet_names_phase''));',...
    'set(findobj(gcbf,''tag'',''fmint''),''visible'',''on'');   set(findobj(gcbf,''tag'',''fmin''),''visible'',''on'',''string'',''2'');',...
    'set(findobj(gcbf,''tag'',''fmaxt''),''visible'',''on'');   set(findobj(gcbf,''tag'',''fmax''),''visible'',''on'');',...
    'set(findobj(gcbf,''tag'',''fstept''),''visible'',''on'',''string'',''freq step''); set(findobj(gcbf,''tag'',''fstep''),''visible'',''on'',''string'',''5'');',...  
    'set(findobj(gcbf,''tag'',''logt''),''visible'',''on''); set(findobj(gcbf,''tag'',''logcb''),''visible'',''on'',''value'',0);',...
    'set(findobj(gcbf,''tag'',''cmint''),''visible'',''on''); set(findobj(gcbf,''tag'',''cmin''),''visible'',''on'');',...
    'set(findobj(gcbf,''tag'',''cmaxt''),''visible'',''on''); set(findobj(gcbf,''tag'',''cmax''),''visible'',''on'');',...
    'end;',...
     ];

geometry = {[7,7,1], [7,7,1], [1], [7,7,1], [2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 1], [2.3, 2.3, 2.3, 2.3, 5.6], [1], [7,7,1], [7,7,1]};
uilist   = {...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','sigsel','callback',cb_sigchanged},{},...
    {'Style','text','String','Domain :'},...
    {'Style','popupmenu','String',domainsInit,'tag','domainsel','callback',cb_domainchanged},{},... % Wavelet parameters
    {},...
    {'Style','text','String','wavelet name :','visible','off','tag','wnamet'},...
    {'Style','popupmenu','String',vi_defaultval('wavelet_names'),'visible','off','tag','wname','Callback',cb_wavnamechanged},...
    {'Style','text','String','Log','fontsize',4,'tag','logt','visible','off'},...
    {'Style','text','String','freq min :','visible','off','tag','fmint'},...
    {'Style','edit','String','1','visible','off','tag','fmin'},...
    {'Style','text','String','freq max :','visible','off','tag','fmaxt'},...
    {'Style','edit','String',fmaxstr,'visible','off','tag','fmax'},...
    {'Style','text','String','freq step :','visible','off','tag','fstept'},...
    {'Style','edit','String','5','visible','off','tag','fstep'},...
    {'Style','checkbox','tag','logcb','visible','off','callback',cb_logcbcheck},...
    {'Style','text','String','cycle min :','visible','off','tag','cmint'},...
    {'Style','edit','String',num2str(vi_defaultval('wav_cycle_min')),'visible','off','tag','cmin'},...
    {'Style','text','String','cycle max :','visible','off','tag','cmaxt'},...
    {'Style','edit','String',num2str(vi_defaultval('wav_cycle_max')),'visible','off','tag','cmax'},...
    {},...
    {},...
    {'Style','text','String','Window :'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(ALLWIN),...
        'tag','winsel','callback',cb_winchanged},{},...
    {'Style','text','String','Position :'},...
    {'Style','edit','String',num2str(position),'tag','possel'},{},...
};
results = inputgui ('geometry',geometry,'uilist',uilist,'title','View parameters');

if ~isempty(results)
    viewparams = [];
    domainstr=domainsshort{results{2}};
    sigdesc = sigdesc{results{1}};
    Sig     = ALLSIG(find(strcmp(sigdesc,{ALLSIG.desc})==1));
    sigid   = Sig.id;
    switch domainstr
        % TODO verification des valeurs...
        case 'tf'
            wnames              = vi_defaultval('wavelet_names');
            viewparams.wname    = wnames{results{3}};
            viewparams.pfmin    = max(1,str2double(results{4}));
            viewparams.pfmax    = str2double(results{5});
            viewparams.pfstep   = str2double(results{6});
            viewparams.logscale = results{7};
            if strcmp(viewparams.wname,'cmor-var')
                viewparams.cyclemin = str2double(results{8});
                viewparams.cyclemax = str2double(results{9});
            else
                viewparams.cyclemin = [];
                viewparams.cyclemax = [];                
            end
            tfNormMethods       = vi_defaultval('tf_norm_method');
            viewparams.norm     = tfNormMethods{1};
        case 'ph'
            wnames              = vi_defaultval('wavelet_names_phase');
            viewparams.wname    = wnames{results{3}};
            viewparams.pfmin    = max(1,str2double(results{4}));
            viewparams.pfmax    = str2double(results{5});
            viewparams.pfstep   = str2double(results{6});
            viewparams.logscale = results{7};
            if strcmp(viewparams.wname,'cmor-var')
                viewparams.cyclemin = str2double(results{8});
                viewparams.cyclemax = str2double(results{9});
            else
                viewparams.cyclemin = [];
                viewparams.cyclemax = [];                
            end
        case 'f'
            viewparams.fmin     = str2double(results{4});
            viewparams.fmax     = str2double(results{5});
            viewparams.nfft     = str2double(results{6});
            viewparams.logscale = results{7};
            methodsnames        = vi_defaultval('psd_methods');
            viewparams.method   = methodsnames{results{3}};
            if isnan(viewparams.fmin) || isnan(viewparams.fmax)
                msgbox ('Frequencies must be numeric between 0 and FS/2');
                return;
            end
            if viewparams.fmin<0 || viewparams.fmax<0 || viewparams.fmin>Sig.srate/2 || viewparams.fmax>Sig.srate/2
                msgbox ('Frequencies must be numeric between 0 and FS/2');
                return;
            end
            if viewparams.fmin>viewparams.fmax
                oldminsave = viewparams.fmin;
                viewparams.fmin = viewparams.fmax;
                viewparams.fmax = oldminsave;
            end
    end
    [VI, ALLWIN, ALLSIG]  = addview (VI, ALLWIN, ALLSIG, results{10}, sigid, domainstr, str2double(results{11}), viewparams);   
end


end





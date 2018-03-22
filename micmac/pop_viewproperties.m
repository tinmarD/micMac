function [VI, ALLWIN, ALLSIG] = pop_viewproperties(VI, ALLWIN, ALLSIG, delete, position, couleur, tfNormMethod)
% [VI, ALLWIN, ALLSIG] = pop_viewproperties(VI, ALLWIN, ALLSIG)
% or [...] = pop_viewproperties(VI, ALLWIN, ALLSIG, delete, position, couleur)
% For T-F views, color is the colormap (TODO) (Not possible to have several
% colormaps at the same time in Matlab R2013a)
%
% Delete a view : 
%       pop_viewproperties(VI, ALLWIN, ALLSIG, 1)
%
% Change view's position : 
%       pop_viewproperties(VI, ALLWIN, ALLSIG, 0, pos)
%
% Change view's color (time and frequency views)
%       pop_viewproperties(VI, ALLWIN, ALLSIG, 0, -1, couleur)
%
% Change view's normalization (time-frequency views)
%       pop_viewproperties(VI, ALLWIN, ALLSIG, 0, -1, -1, norm)
%  Normalization/Scale can be 'Log' (default), 'Z-score', 'None'


results = [];

if nargin==3
    
    %- get the view name
    viewname    = get(gcbo,'Label');
    %- Retrieve the signal name
    spacepos    = regexp (viewname,' ','once');
    seppos      = regexp (viewname,'-');
    viewid      = str2double(viewname (1:spacepos-1));
    sigdesc     = viewname (spacepos+1:seppos(end)-1);
    domainstr   = viewname (seppos(end)+1:end);

    switch domainstr
        case 't'; domainstr='time';
        case 'f'; domainstr='frequency';
        case 'tf';domainstr='time-frequency';
    end

    Sig = getsigfromdesc (ALLSIG,sigdesc);
    [View,winnb,viewpos] = getview (ALLWIN, viewid);
    viewposstr = cell(1,length(ALLWIN(winnb).views));
    for i=1:length(viewposstr); viewposstr{i}=num2str(i); end;

    cb_colorchooser     = ['couleur = uisetcolor([',num2str(View.couleur),...
        ']);set(gcbf,''userdata'',struct(''couleur'',couleur));'];
    cb_remove           = ['set(gcbf,''userdata'',struct(''delete'',1));',...
        'set(findobj(''parent'', gcbf, ''tag'', ''ok''), ''userdata'', ''retuninginputui'');'];
    
    switch domainstr
        case 'time';            geometry = {[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1],[1,2]};  
        case 'frequency';       geometry = {[1,1],[1,1],[1,1],[1,1],[1,1],[1],[1,1],[1,1,1,1,1,1],[1,1],[1],[1,2]};
        case 'time-frequency';	geometry = {[1,1],[1,1],[1,1],[1,1],[1,1],[1],[1,1],[1,1,1,1,1,1],[1,1],[1,1],[1],[1,2]};
    end
    uilist=cell(1,length([geometry{:}]));
    
    uilist(1:10) = {...
        {'Style','text','String','Signal:'},...
        {'Style','text','String',sigdesc},...
        {'Style','text','String','Montage'},...
        {'Style','text','String',Sig.montage},...
        {'Style','text','String','Visualization domain'},...
        {'Style','text','String',domainstr},...
        {'Style','text','String','Window number'},...
        {'Style','text','String',num2str(winnb)},...
        {'Style','text','String','Position'},...
        {'Style','popupmenu','String',viewposstr,'Value',viewpos},...
    };
    uilist(end-4:end) = {
                {'Style','text','String','Color'},...
                {'Style','pushbutton','String','choose','Callback',cb_colorchooser},...
                {},...
                {'Style','pushbutton','String','Remove','Callback',cb_remove},{},...
                };
    

    switch domainstr
        case 'frequency'
            methodPos   = find(strcmp(vi_defaultval('psd_methods'),View.params.method));
            uilist(11:end-5) = {
                {},...
                {'Style','text','String','Method :'},...
                {'Style','popupmenu','String',vi_defaultval('psd_methods'),'value',methodPos},...
                {'Style','text','String','freq min :','tag','fmint'},...
                {'Style','edit','String',num2str(View.params.fmin),'tag','fmin'},...
                {'Style','text','String','freq max :','tag','fmaxt'},...
                {'Style','edit','String',num2str(View.params.fmax),'tag','fmax',},...
                {'Style','text','String','nfft:','tag','fstept'},...
                {'Style','edit','String',num2str(View.params.nfft),'tag','fstep'}};
            
        case 'time-frequency'
            wavePos     = find(strcmp(vi_defaultval('wavelet_names'),View.params.wname));
            colormapPos = find(strcmp(vi_graphics('colormaps'),VI.guiparam.colormap));
            tfNormPos   = find(strcmp(vi_defaultval('tf_norm_method'),View.params.norm));
            uilist(11:end-3) = {
                {},...
                {'Style','text','String','Wavelet name :','tag','wnamet'},...
                {'Style','popupmenu','String',vi_defaultval('wavelet_names'),'tag','wname','value',wavePos},...
                {'Style','text','String','freq min :','visible','off','tag','fmint'},...
                {'Style','edit','String',num2str(View.params.pfmin),'tag','fmin'},...
                {'Style','text','String','freq max :','tag','fmaxt'},...
                {'Style','edit','String',num2str(View.params.pfmax),'tag','fmax',},...
                {'Style','text','String','freq step :','tag','fstept'},...
                {'Style','edit','String',num2str(View.params.pfstep),'tag','fstep'},...
                {'Style','text','String','Normalisation method :'},...
                {'Style','popupmenu','String',vi_defaultval('tf_norm_method'),'Value',tfNormPos},...
                {'Style','text','String','Colormap'},...
                {'Style','popupmenu','String',vi_graphics('colormaps'),'value',colormapPos}};
    end
            
    [results, userdata] = inputgui (geometry, uilist, 'title', 'View properties');
    
elseif nargin>3 && nargin<8
    % Retrieve window and view number
    winnb   = find(cat(1,ALLWIN.figh)==gcbf);
    Win     = ALLWIN(winnb);
    if isempty(Win.axlist==gca); return; end;
    viewpos = getfocusedviewpos(Win, gca);
    viewid  = Win.views(viewpos).id;

    if delete
        ALLWIN = deleteview(VI,ALLWIN, ALLSIG, viewid);
        ALLWIN = redrawwin(VI,ALLWIN,ALLSIG,winnb);
        return;
    elseif nargin>5
        if position==-1; position=viewpos; end;
        if length(couleur)==3 && isnumeric(couleur) || isequal(couleur,'rainbow')
            ALLWIN(winnb).views(viewpos).couleur = couleur;
        end
    end
else
    warning ('Wrong number of arguments in pop_viewproperties');
    eval    ('help pop_viewproperties');
    return;
end


if ~isempty(results) || nargin>3
    % Save gcbf before potentially removing the menu (calling this callback)
%     gcbfsaved = gcbf;
    if nargin==3 && isfield(userdata,'delete')
        ALLWIN = deleteview(VI,ALLWIN, ALLSIG, viewid);
    elseif nargin==3 && isfield(userdata,'couleur')
        ALLWIN(winnb).views(viewpos).couleur = userdata.couleur;
    end
    
%     if strcmp(domainstr,'time-frequency')
%         colormaps   = vi_graphics('colormaps');
%         colormapPos = results{2};
%         ALLWIN(winnb).views(viewpos).couleur = colormaps{colormapPos};
%     end
        
    if nargin==3; newviewpos=results{1}; else newviewpos=position; end;
    
    %- Change View Position
    %- if viewpos is not in last position, permute the 2 views
    if viewpos ~= newviewpos
        %- Get corresponding channel if the leading view changes
        if viewpos == 1
            ALLWIN(winnb).chansel   = getcorrchannels (VI,ALLWIN, ALLSIG, winnb, newviewpos);
        elseif newviewpos == 1
            corrchansel             = getcorrchannels (VI,ALLWIN, ALLSIG, winnb, viewpos);
            %- If visu mode is spaced, keep the same number of channel
            if ALLWIN(winnb).visumode == 2
                corrchansel = corrchansel (1:min(length(corrchansel),length(ALLWIN(winnb).chansel)));
            end
        	ALLWIN(winnb).chansel   = corrchansel;
        end
        if isempty(ALLWIN(winnb).chansel); ALLWIN(winnb).chansel=1; end;
        Viewsave    = ALLWIN(winnb).views(newviewpos);
        ALLWIN(winnb).views(newviewpos)      = ALLWIN(winnb).views(viewpos);
        ALLWIN(winnb).views(viewpos)         = Viewsave;
    end
    
    %- Change TF-view normalization method
    if nargin==7 && strcmpi(ALLWIN(winnb).views(viewpos).domain,'tf')
        ALLWIN(winnb).views(viewpos).params.norm = tfNormMethod;
    end
        
    %- Time-frequency view
    if nargin==3 && strcmp(domainstr,'time-frequency')
        wavnames    = vi_defaultval('wavelet_names');
        normMethods = vi_defaultval('tf_norm_method');
        colormaps   = vi_graphics('colormaps');
        ALLWIN(winnb).views(newviewpos).params.wname    = wavnames{results{2}};
        ALLWIN(winnb).views(newviewpos).params.pfmin    = str2double(results{3});
        ALLWIN(winnb).views(newviewpos).params.pfmax    = str2double(results{4});
        ALLWIN(winnb).views(newviewpos).params.pfstep   = str2double(results{5});
        ALLWIN(winnb).views(newviewpos).params.norm     = normMethods{results{6}};
        VI.guiparam.colormap = colormaps{results{7}};
        colormap(colormaps{results{7}});
    elseif nargin==3 && strcmp(domainstr,'frequency')
        psdMethods  = vi_defaultval('psd_methods');
        ALLWIN(winnb).views(newviewpos).params.method   = psdMethods{results{2}};
        ALLWIN(winnb).views(newviewpos).params.fmin     = str2double(results{3});
        ALLWIN(winnb).views(newviewpos).params.fmax     = str2double(results{4});
        ALLWIN(winnb).views(newviewpos).params.nfft     = str2double(results{5});
    end
    
    
    ALLWIN = redrawwin(VI,ALLWIN,ALLSIG,winnb);
    
end


end

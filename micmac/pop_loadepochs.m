function [VI, ALLWIN, ALLSIG] = pop_loadepochs (VI, ALLWIN, ALLSIG, type)
% [VI, ALLWIN, ALLSIG] = POP_LOADMNEEPOCHS (VI, ALLWIN, ALLSIG, type)
% Load MNE Epochs

if ~isempty(findobj('type','figure','name','Signal description'))
    figure(findobj('type','figure','name','Signal description'));
    return;
end

if strcmpi(type, 'mne')
    filetypes = {'*epo.fif'};
elseif strcmp(type, 'eeglab')
    filetypes = {'*.dat'};
end

[filename, filepath] = uigetfile(filetypes, 'Select the EEG file ');

if ~ischar(filename); return; end;
dispinfo ('Loading epochs...',1);


try
    if strcmpi(type,'mne')
        MNEepoch = fiff_read_epochs(fullfile(filepath,filename));
        Sig = mneepoch2sig (MNEepoch);
    elseif strcmpi(filetype,'eeglab')
        disp('TOOD');
    else
        warning ('Epoch type unrecognized in pop_loadepochs');
        Sig = [];
    end
catch err
    dispinfo('Could not load epochs');
    warning('Could not load epochs');
    disp([err.identifier,' : ',err.message]);
    Sig = [];
end

dispinfo ('');
if ~isempty(Sig)
    %- Pré-remplissage des paramètres
    sigdescdef  = fastif(length(filename>4),filename(1:end-4),filename); 
    montagedef  = fastif(isempty(regexp(Sig.channames{1},'-','once')),...
                    'monopolar','bipolar');
    windowsnb   = cell(1,VI.nwin);
    position    = length(ALLWIN(end).views)+1;
    %- Check that the same file does not already exist
    if ~isempty(getsignal(ALLSIG,'filename',filename,'filepath',filepath,'israw',1))
        dispinfo ('Signal already loaded');
        return;
    end
    [~,rawsigdesc]  = getrawsignals(ALLSIG);

    %- Add the signal temporarily (to be able to create channel
    % correspondences) - with the defaults parameters
    [VI, ALLWIN, ALLSIG, sigid] = addsignal (VI, ALLWIN, ALLSIG, Sig.data, Sig.channames, ...
        Sig.srate, 'epoch', Sig.tmin, Sig.tmax, Sig.filename, Sig.filepath, montagedef, sigdescdef, 1, -1, []);
    assignin ('base','ALLSIG',ALLSIG);
    assignin ('base','VI',VI);
    %- Add events for each epoch
    VI = addmneepochevents (VI, ALLWIN, ALLSIG, MNEepoch, sigid);

    for w=1:VI.nwin; windowsnb{w}=w; end;
    cb_winchanged = [
        'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
        'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
        'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
        'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

    cb_chancorr = [
        'sigpos1     = length(ALLSIG);',...
        'disp(length(ALLSIG));',...
        'sigdesc     = get(findobj(gcbf, ''tag'', ''sigdesclb''),''String'');',...
        'pos         = get(findobj(gcbf, ''tag'', ''sigdesclb''),''Value'');',...
        '[~,sigpos2] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
        '[chancorr, chancorrinv] = pop_chancorr (VI, ALLSIG, sigpos1, sigpos2);',...
        'set(gcbf,''userdata'',struct(''sigpos1'',sigpos1,''sigpos2'',sigpos2',...
        ',''chancorr'',chancorr,''chancorrinv'',chancorrinv));',...
        ];
    geometry = {[1,1],[1,1],[1],[2,2,0.5],[1],[1,1],[1,1,1,1]};
    uilist   = {...
        {'Style','text','String','Montage type :'},...
        {'Style','edit','String',montagedef},...
        {'Style','text','String','Signal description :'},...
        {'Style','edit','String',sigdescdef,'tag','sigdesc1'},...
        {},...
        {'Style','text','String','Channel correspondency with signal :'},...
        {'Style','popupmenu','String',rawsigdesc,'tag','sigdesclb'},...
        {'Style','pushbutton','String','See','Callback',cb_chancorr},...
        {},...
        {'Style','text','String','Add view'},...
        {'Style','checkbox','Value',1},...
        {'Style','text','String','Window'},...
        {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
        {'Style','text','String','Position'},...
        {'Style','edit','String',num2str(position),'tag','possel'},...
    };
    if isempty(rawsigdesc)
        geometry = geometry ([1:3,6:7]);
        uilist   = uilist ([1:5,10:15]);
    end
    [results, userdata] = inputgui (geometry, uilist, 'title', 'Signal description');
    if ~isempty(results)
        % Modify the signal
        ALLSIG(end).montage = results{1};
        ALLSIG(end).desc    = results{2};
        % Modify the uimenu
        set (findobj(gcbf,'type','uimenu','Label',sigdescdef),'Label',results{2});
        % Add a view if asked 
        if fastif(isempty(rawsigdesc),results{3},results{4})
            winnb   = fastif (isempty(rawsigdesc),results{4},results{5});
            if isempty(rawsigdesc); viewpos=results{5}; else viewpos=results{6}; end;
            [VI, ALLWIN, ALLSIG] = addview (VI, ALLWIN, ALLSIG, winnb,sigid,'t',viewpos);
        end
        % Add channel correlation if present
        if ~isempty(userdata)
        	VI = addchancorr(VI,userdata.sigpos1,userdata.sigpos2,userdata.chancorr,userdata.chancorrinv);
            [ALLWIN] = redrawwin (VI, ALLWIN, ALLSIG);
        end
    else
        % Remove the signal
        [VI, ALLWIN, ALLSIG] = deletesignal(VI, ALLWIN, ALLSIG, ALLSIG(end).id);
    end
end


end



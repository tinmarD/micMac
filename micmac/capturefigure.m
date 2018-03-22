function [] = capturefigure (VI, ALLWIN, ALLSIG, type)
%[] = CAPTUREFIGURE (VI, ALLWIN, ALLSIG, type)
% Capture a screeshot of the views in the selected window
%
% type input can be : 
%   'simple'    : Save a global screenshot of the micMac interface
%   'full'      : Save every view in a seperate image file (default: emf
%   format). All images are saved in the same folder
%
% All screenshots are saved in a folder specified in vi_default() as
% 'capture_dir'

winnb = find(cat(1,ALLWIN.figh)==gcbf);
if isempty(ALLWIN(winnb).views); return; end;
Win         = ALLWIN(winnb);
firstView   = Win.views(1);
Sig         = getsignal (ALLSIG, 'sigid', firstView.sigid);
  
%- Check that the capture directory exist
if ~exist(vi_defaultval('capture_dir'),'file')
    msgbox (['The current capture directory : ',vi_defaultval('capture_dir'),...
        ' does not exist. Create it or change the location in the file ''vi_defaultval.m'' to an existing directory.'],'Capture Directory Error');
    return;
end

%-- Simple Capture
if strcmpi(type,'simple')
    defaultfilename = [Sig.desc,'_'];
    filename        = inputdlg ({'Filename : '},'Capture Save',1,{defaultfilename});
    if isempty(filename); return; end;
    filename        = [cell2mat(filename),'.png'];
    %- If a file with the same name already exists, increment the filename
    if exist(fullfile(vi_defaultval('capture_dir'),filename),'file')
        filename = [filename(1:end-4),'_2','.png'];
        inc = 3;
        while exist(fullfile(vi_defaultval('capture_dir'),filename),'file')
            filename = regexprep (filename,'_\d+.png',['_',num2str(inc),'.png']);
            inc = inc+1;
        end
    end
    set (gcbf,'PaperPositionMode','auto');
    set (gcbf,'InvertHardcopy','off');
%     print('-djpeg98',fullfile(vi_defaultval('capture_dir'),filename))
%     set (gcf, 'paperpositionmode', 'manual','paperposition',[0 0 50 35])
    print('-dpng',fullfile(vi_defaultval('capture_dir'),filename), vi_defaultval('captureQuality')); 
    
%-- Full Capture
elseif strcmp(type,'full')
    defaultdirname  = Sig.desc;
    dirname         = cell2mat(inputdlg ({'Directory name :'},'Capture Save',1,{defaultdirname}));
    if isempty(dirname); return; end;
    if exist(fullfile(vi_defaultval('capture_dir'),dirname),'file')
        dirname = [dirname,'_2'];
        inc = 3;
        while exist(fullfile(vi_defaultval('capture_dir'),dirname),'file')
            dirname = regexprep (dirname,'_\d+',['_',num2str(inc)]);
            inc = inc+1;
        end
    end
    if mkdir(fullfile(vi_defaultval('capture_dir'),dirname)) ~= 1
        error (['Could not create capture directory : ',fullfile(vi_defaultval('capture_dir'),dirname)]);
    end
    
    tempfig = figure('units','normalized','outerposition',[0 0 1 1]);
    for i=1:length(Win.views)
    	copyobj(Win.axlist(i),tempfig);
        set (gca,'Units','normalized');
        set (gca,'Position',[0.13,0.13,0.775,0.775]);
        viewSig  = getsignal(ALLSIG,'sigid',Win.views(i).sigid);
    	viewname = [viewSig.desc,'_',Win.views(i).domain];
        viewpath = fullfile(vi_defaultval('capture_dir'),dirname,viewname);
        viewpath = regexprep(viewpath,'>','Sup');
        viewpath = regexprep(viewpath,'<','Inf');
        if exist(fullfile(vi_defaultval('capture_dir'),dirname),'file')
            viewpath = [viewpath,'_2'];
            inc = 3;
            while exist(viewpath,'file')
                viewpath = regexprep (viewpath,'_\d+.jpg',['_',num2str(inc),'.jpg']);
                inc = inc+1;
            end
        end
        try saveas (tempfig,[viewpath,'.emf'],'emf'); catch; end;
        print(tempfig,'-dpng',viewpath,vi_defaultval('captureQuality')); 
        delete(gca);
    end
    close(tempfig);
end
    

end


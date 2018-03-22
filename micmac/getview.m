function [views, winnb, viewpos, viewid, sigid, domain] = getview(ALLWIN, varargin)
% [views, winnb, viewpos, viewid, sigid, domain] = ...
%               getview (ALLWIN, varargin)
% To get all views : [...] = getview (ALLWIN)
% To select views  : [...] = getview (ALLWIN, viewid, sigid, domain, winnb)
%       Or         : [...] = getview (ALLWIN,'domain','tf','sigid',4)

nbview  = sum(arrayfun (@(x)length(x.views),ALLWIN)); 


views   = cell  (1,nbview);
viewid  = zeros (1,nbview);
winnb   = zeros (1,nbview);
viewpos = zeros (1,nbview);
sigid   = zeros (1,nbview);
domain  = cell  (1,nbview);

if nargin==1
    inc = 1;
    for i=1:length(ALLWIN)
        w = ALLWIN(i);
        for j=1:length(w.views)
            views{inc}  = w.views(j);
            viewid(inc) = w.views(j).id;
            sigid(inc)  = w.views(j).sigid;
            domain{inc} = w.views(j).domain;
            winnb(inc)  = i;
            viewpos(inc)= j;
            inc = inc+1;
        end
    end
    views = cell2mat(views);
else
    
    p = inputParser;
    addOptional (p, 'viewid',   [],     @isnumeric);
    addOptional (p, 'sigid',    [],     @isnumeric);
    addOptional (p, 'domain',   []);
    addOptional (p, 'winnb',    [],     @isnumeric);
    parse (p,varargin{:});

    [allviews, winnb, viewpos, viewid, sigid, domain] = getview(ALLWIN);
    viewsel     = ones(1,nbview);
    if ~isempty(p.Results.viewid)
        viewsel = viewsel & ismember(viewid,p.Results.viewid);
    end
    if ~isempty(p.Results.sigid)
        viewsel = viewsel & ismember(sigid,p.Results.sigid);
    end
    if ~isempty(p.Results.domain)
        viewsel = viewsel & ismember(domain,p.Results.domain);
    end
    if ~isempty(p.Results.winnb)
        viewsel = viewsel & ismember(winnb,p.Results.winnb);
    end
    
    views   = allviews(viewsel);
    viewid  = viewid  (viewsel);
    sigid   = sigid   (viewsel);
    domain  = domain  (viewsel);
    winnb   = winnb   (viewsel);
    viewpos = viewpos (viewsel);

end


end


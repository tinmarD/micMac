function [Sigs, sigsel, sigid, parent, desc, filename, filepath, israw, sigtype] = ...
getsignal(ALLSIG, varargin)
% [Sigs, sigsel, sigid, parent, desc, filename, filepath, israw, type] = ...
% GETSIGNAL(ALLSIG, varargin)
% Search for signals who match input criteria
% 
% INPUTS:
%   - ALLSIG
% Optional Inputs:
%   - 'sigid'           : ID of the signal
%   - 'type'            : Type of the signal
%   - 'parent'          : ID of the parent signal (-1 if raw)
%   - 'desc'            : Description of the signal
%   - 'filename'        : Filename of the signal
%   - 'filepath'        : Filepath of the signal
%   - 'israw'           : 1 if raw signal 0 otherwise
%
% OUTPUTS:
%   - Sigs              : Signals matching inputs criteria
%   - sigsel            : Indices of the matching signals [logical vector]
%   - sigid             : Matching signals IDs
%   - parent            : Matching signals parent IDs
%   - desc              : Matching signals descriptions
%   - filename          : Matching signals filenames
%   - filepath          : Matching signals filepaths
%   - israw             : Matching signals raw field
%   - sigtype           : Matching signals type field
%
% See also getsigfromid,  getsigchildren, getsigfromdesc


Sigs    = [];
sigsel  = [];
sigid   = [];
parent  = [];
desc    = {};
filename= {};
filepath= {};
israw   = [];

nsig  = length(ALLSIG);
if nsig==0; return; end;

sigid       = [ALLSIG.id];
sigtype     = {ALLSIG.type};
parent      = [ALLSIG.parent];
desc        = {ALLSIG.desc}; %arrayfun(@(x)x.desc,ALLSIG,'Uniformoutput',false);
filename    = {ALLSIG.filename};
filepath    = {ALLSIG.filepath};
israw       = [ALLSIG.israw];

p = inputParser;
addOptional (p, 'sigid',    [],     @isnumeric);
addOptional (p, 'type',     []);
addOptional (p, 'parent',   [],     @isnumeric);
addOptional (p, 'desc',     []);
addOptional (p, 'filename', []);
addOptional (p, 'filepath', []);
addOptional (p, 'israw',    [],     @isnumeric);

parse (p,varargin{:});

sigsel = ones(1,nsig);
if ~isempty(p.Results.sigid)
    sigsel = sigsel & ismember(sigid,p.Results.sigid);
end
if ~isempty(p.Results.type)
    sigsel = sigsel & ismember(sigtype,p.Results.type);
end
if ~isempty(p.Results.parent)
    sigsel = sigsel & ismember(parent,p.Results.parent);
end
if ~isempty(p.Results.desc)
    sigsel = sigsel & ismember(desc,p.Results.desc);
end
if ~isempty(p.Results.filename)
    sigsel = sigsel & ismember(filename,p.Results.filename);
end
if ~isempty(p.Results.filepath)
    sigsel = sigsel & ismember(filepath,p.Results.filepath);
end
if ~isempty(p.Results.israw)
    sigsel = sigsel & ismember(israw,p.Results.israw);
end

sigsel      = logical   (sigsel);
sigtype     = sigtype   (sigsel);
Sigs        = ALLSIG    (sigsel);
sigid       = sigid     (sigsel);
parent      = parent    (sigsel);
desc        = desc      (sigsel);
filename    = filename  (sigsel);
filepath    = filepath  (sigsel);
israw       = israw     (sigsel);

end


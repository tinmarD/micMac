function [ Sig ] = mneepoch2sig(raw_epoch)
% Sig = MNEEPOCH2SIG raw_epoch)
%   Convert a MNE epoch structure to a micMac Sig structure
% 
% INPUTS : 
%   - raw_epoch      : MNE epoch structure
%
% OUTPUTS : 
%   - Sig           : micMac Sig structure
%
% See also eeglabepoch2sig

seps = strfind(raw_epoch.info.filename,filesep);
dirpath = raw_epoch.info.filename(1:seps(end));
filename = raw_epoch.info.filename(seps(end)+1:end);

Sig = s_emptysig();
Sig.srate           = raw_epoch.info.sfreq;
Sig.type            = 'epoch';
Sig.data            = raw_epoch.data;
if max(Sig.data(:)) > 1
    Sig.data = Sig.data / 1E6;
end
Sig.filename        = filename;
Sig.filepath        = dirpath;
Sig.nchan           = raw_epoch.info.nchan;
Sig.npnts           = size(raw_epoch.data, 3);
Sig.tmax            = raw_epoch.tmax;
Sig.channames       = raw_epoch.info.ch_names;
Sig.channames       = cellfun(@(x)deblank(x),Sig.channames,'UniformOutput',0);
Sig.channamesnoeeg  = Sig.channames;
Sig.eegchannelind   = 1:Sig.nchan;
% For epochs only : 
Sig.ntrials         = size(raw_epoch.data, 1);
Sig.tmin            = raw_epoch.tmin;
Sig.badepochpos     = [];

end


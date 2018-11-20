function [ Sig_resample ] = resamplesig(Sig, new_srate, chanselpos, tmin, tmax)
%[ Sig_resample ] = RESAMPLESIG(Sig, new_srate, chanselpos, tmin, tmax)
%   Resample micMac signal Sig at the new sampling frequency new_srate
%   If only a subset of channel must be selected before resampling, use the
%   chanselpos argument (channel position vector)
%   To select a time period before resampling use the tmin, tmax arguments
%   The script uses the pop_resample EEGLAB structure

if nargin < 3
    chanselpos =[];
end
if ~isnumeric(chanselpos)
    chanselpos = [];
end
if nargin < 5
    tmin = [];
    tmax = [];
else
    tmin_backup = tmin;
    % Make sure 
    tmin = min(tmin, tmax);
    tmax = max(tmin_backup, tmax);
end

EEG = sig2eeg(Sig);

%- Select channels if asked
if ~isempty(chanselpos)
    EEG = pop_select(EEG, 'channel', chanselpos);
end
%- Select time range if asked
if ~isempty(tmin) && ~isempty(tmax)
    EEG = pop_select(EEG, 'time', [tmin, tmax]);
end

EEG_resample = pop_resample(EEG, new_srate);

Sig_resample = eeg2sig(EEG_resample, Sig.filepath, Sig.filename);

Sig_resample.badchannelpos  = Sig.badchannelpos;
Sig_resample.badepochpos    = Sig.badepochpos;
Sig_resample.ntrials        = Sig.ntrials;
Sig_resample.montage        = Sig.montage;
Sig_resample.israw          = Sig.israw;
Sig_resample.desc           = [Sig.desc,'-',num2str(new_srate),'Hz'];
Sig_resample.parent         = -1;

end


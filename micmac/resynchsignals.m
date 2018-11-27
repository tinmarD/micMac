function [toffset, SigA, SigB] = resynchsignals(SigA, SigB, chanposA, chanposB, ...
    tmin, tmax, maxlag, resamplefreq, toffset, strategy)
%[toffset] = RESYNCHSIGNALS(SigA, SigB, chanposA, chanposB)
%   Find the time offset between micMac Signals SigA and SigB, based on
%   2 channels that must have physical correspondency defined by chanposA
%   and chanposB
%   To find the time offset, the cross correlation is done of channel A
%   with channel B in the time interval tmin < t < tmax
%   The 2 signals are resampled at resamplefreq, to get more precise
%   results, choose a high sampling rate (but it will take longer)
%   A max lag can be set if we know a limit of the time offset.
%   For all these set toffset to NaN
%     
% 
%   If you already know the time offset, set the toffset argument (time
%   offset in seconds). This function will then skip the cross-correlation
%   step.
%
%   Two strategies are availaible to resynch the signal
%       * 'AddBlank' : Add a blank signal at the beggining of the late
%       signal
%       * 'Cut' : Cut the start of the ahead signal
%   This is specfied with the strategy argument
SigAsynch = [];
SigBsynch = [];

if isempty(toffset)
    toffset = NaN;
end

% Check that SigA and SigB are different
if SigA.id == SigB.id
    msgbox('SigA and SigB must be different');
end

if exist('resample') == 2
    usesigproc = 1;
else
    usesigproc = 0;
end

if isnan(toffset)
    %   Resample the channels with the required sampling frequency.
    %   Select time interval at the same time
    if SigA.srate ~= resamplefreq
        if usesigproc
            chanA = SigA.data(chanposA, max(1,1+tmin*SigA.srate):min(SigA.npnts,1+tmax*SigA.srate));
            chanA = resample(chanA, resamplefreq, SigA.srate);
        else
            SigAsel = resamplesig(SigA, resamplefreq, chanposA, tmin, tmax);
            chanA = SigAsel.data(1,:);
        end
    else
        chanA = SigA.data(chanposA,max(1,1+tmin*SigA.srate):min(SigA.npnts,1+tmax*SigA.srate));
    end
    if SigB.srate ~= resamplefreq
        if usesigproc
            chanB = SigB.data(chanposB,max(1,1+tmin*SigB.srate):min(SigB.npnts,1+tmax*SigB.srate));
            chanB = resample(chanB, resamplefreq, SigB.srate);
        else
            SigBsel = resamplesig(SigB, resamplefreq, chanposB, tmin, tmax);
            chanB = SigBsel.data(1,:);
        end
    else
        chanB = SigB.data(chanposB,max(1,1+tmin*SigB.srate):min(SigB.npnts,1+tmax*SigB.srate));
    end

    maxlag_sample = round(maxlag*resamplefreq);
    xcorr_ab = xcorr(chanA, chanB, maxlag_sample);
    [~, xcorr_argmax] = max(xcorr_ab);
    times = linspace(-maxlag, maxlag, length(xcorr_ab));
    toffset = times(xcorr_argmax);
%     % 
%     [~, xcorr_argmax] = max(xcorr_ab);
%     M = max(length(chanA), length(chanB));
%     times = linspace(-M/resamplefreq, M/resamplefreq, 2*M-1);
%     toffset = times(xcorr_argmax);
end

if ~isempty(strategy)
    if strcmpi(strategy,'addblank')
        % Add a blank signal before the late signal
        if toffset > 0  % Sig A is ahead of Sig B
            toffset_sample = round(toffset*SigB.srate);
            SigB.data   = [zeros(SigB.nchan,toffset_sample), SigB.data];
            SigB.npnts  = SigB.npnts+toffset_sample;
            SigB.tmax   = SigB.tmax+toffset;
            SigB.desc   = [SigB.desc,'-sync'];
        elseif toffset < 0  % Sig B is ahead of Sig A
            toffset_sample = round(abs(toffset)*SigA.srate);
            SigA.data   = [zeros(SigA.nchan,toffset_sample), SigA.data];
            SigA.npnts  = SigA.npnts+toffset_sample;
            SigA.tmax   = SigA.tmax+toffset;
            SigA.desc   = [SigA.desc,'-sync'];
        end
    elseif strcmpi(strategy,'cut')
        % Cut the beggining of the ahead signal
        if toffset > 0  % Sig A is ahead of Sig B
            toffset_sample = round(toffset*SigA.srate);
            SigA.data   = SigA.data(:,toffset_sample:end);
            SigA.npnts  = SigA.npnts-toffset_sample;
            SigA.tmax   = SigA.tmax-toffset;
            SigA.desc   = [SigA.desc,'-sync'];
        elseif toffset < 0  % Sig B is ahead of Sig A
            toffset_sample = round(abs(toffset)*SigB.srate);
            SigB.data   = SigB.data(:,toffset_sample:end);
            SigB.npnts  = SigB.npnts-toffset_sample;
            SigB.tmax   = SigB.tmax-toffset;
            SigB.desc   = [SigB.desc,'-sync'];
        end
    else
        error('Wrong strategy argument - Must be ''AddBlank'' or ''Cut''');
    end
end

% if ~isempty(strategy)
%     if strcmpi(strategy,'addblank')
%         % Add a blank signal before the late signal
%         if toffset > 0  % Sig A is ahead of Sig B
%             toffset_sample = round(toffset*SigB.srate);
%             sigBsynch_data = zeros(SigB.nchan, SigB.npnts+toffset_sample);
%             SigBsynch = s_newsig(sigBsynch_data, SigB.channames, SigB.srate, SigB.type, SigB.tmin, ...
%                 SigB.tmax+toffset, SigB.filename, SigB.filepath, SigB.montage, ...
%                 [SigB.desc,'-sync'], SigB.israw, SigB.id, -1, SigB.badchannelpos, SigB.badepochpos);
%             SigBsynch.data(:, toffset_sample+1:end) = SigB.data;
%             SigAsynch = SigA;
%         elseif toffset < 0  % Sig B is ahead of Sig A
%             toffset_sample = round(abs(toffset)*SigA.srate);
%             sigAsynch_data = zeros(SigA.nchan, SigA.npnts+toffset_sample);
%             SigAsynch = s_newsig(sigAsynch_data, SigA.channames, SigA.srate, SigA.type, SigA.tmin, ...
%                 SigA.tmax+toffset, SigA.filename, SigA.filepath, SigA.montage, ...
%                 [SigA.desc,'-sync'], SigA.israw, SigA.id, -1, SigA.badchannelpos, SigA.badepochpos);
%             SigAsynch.data(:, toffset_sample+1:end) = SigA.data;
%             SigBsynch = SigB;
%         else    % No time offset
%             SigAsynch = SigA;
%             SigBsynch = SigB;
%         end
%     elseif strcmpi(strategy,'cut')
%         % Cut the beggining of the ahead signal
%             if toffset > 0  % Sig A is ahead of Sig B
%             toffset_sample = round(toffset*SigA.srate);
%             sigAsynch_data = SigA.data(:,toffset_sample:end);
%             SigAsynch = s_newsig(sigAsynch_data, SigA.channames, SigA.srate, SigA.type, SigA.tmin, ...
%                 SigA.tmax-toffset, SigA.filename, SigA.filepath, SigA.montage, ...
%                 [SigA.desc,'-sync'], SigA.israw, SigA.id, -1, SigA.badchannelpos, SigA.badepochpos);
%             SigBsynch = SigB;
%         elseif toffset < 0  % Sig B is ahead of Sig A
%             SigAsynch = SigA;
%             toffset_sample = round(abs(toffset)*SigB.srate);
%             sigBsynch_data = SigB.data(:,toffset_sample:end);
%             SigBsynch = s_newsig(sigBsynch_data, SigB.channames, SigB.srate, SigB.type, SigB.tmin, ...
%                 SigB.tmax-toffset, SigB.filename, SigB.filepath, SigB.montage, ...
%                 [SigB.desc,'-sync'], SigB.israw, SigB.id, -1, SigB.badchannelpos, SigB.badepochpos);
%         else    % No time offset
%             SigAsynch = SigA;
%             SigBsynch = SigB;
%             end
%     else
%         error('Wrong strategy argument - Must be ''AddBlank'' or ''Cut''');
%     end
% end


end


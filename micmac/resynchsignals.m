function [toffset, SigAsynch, SigBsynch] = resynchsignals(SigA, SigB, chanposA, chanposB, tmin, tmax, toffset, strategy)
%[toffset] = RESYNCHSIGNALS(SigA, SigB, chanposA, chanposB)
%   Find the time offset between micMac Signals SigA and SigB, based on
%   2 channels that must have physical correspondency defined by chanposA
%   and chanposB
%   To find the time offset, the cross correlation is done of channel A
%   with channel B in the time interval tmin < t < tmax
%   If the 2 signals do not have the same sampling frequency, the channel
%   with the lowest sampling freq. is interpolated to match the sampling
%   freq of the other signal.
%   For all these set toffset to NaN
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

if isempty(toffset)
    toffset = NaN;
end

% Check that SigA and SigB are different
if SigA.id == SigB.id
    msgbox('SigA and SigB must be different');
end

if isnan(toffset)
    %   If the 2 signals do not have the same sampling frequency, the channel
    %   with the lowest sampling freq. is interpolated to match the sampling
    %   freq of the other signal. Select time interval at the same time
    if SigA.srate > SigB.srate
        SigBsel = resamplesig(SigB, SigA.srate, chanposB, tmin, tmax);
        chanA = SigA.data(chanposA,max(1,1+tmin*SigA.srate):min(SigA.npnts,1+tmax*SigA.srate));
        chanB = SigBsel.data(1,:);
    elseif SigA.srate < SigB.srate
        SigAsel = resamplesig(SigA, SigB.srate, chanposA, tmin, tmax);
        chanA = SigAsel.data(1,:);
        chanB = SigB.data(chanposB,max(1,1+tmin*SigB.srate):min(SigB.npnts,1+tmax*SigB.srate));
    else
        chanA = SigA.data(chanposA,max(1,1+tmin*SigA.srate):min(SigA.npnts,1+tmax*SigA.srate));
        chanB = SigB.data(chanposB,max(1,1+tmin*SigB.srate):min(SigB.npnts,1+tmax*SigB.srate));
    end

    srate = max(SigA.srate, SigB.srate);
    xcorr_ab = xcorr(chanA, chanB);
    [~, xcorr_argmax] = max(xcorr_ab);
    M = max(length(chanA), length(chanB));
    times = linspace(-M/srate, M/srate, 2*M-1);
    toffset = times(xcorr_argmax);
end
    
% plot results
% figure; 
% subplot(211); hold on;
% plot(chanA);
% plot(chanAfilt,'g');
% subplot(212); hold on;
% plot(chanB);
% plot(chanBfilt,'g');

% figure;
% plot(times, xcorr_ab); hold on;
% plot(times, xcorr_ab_filt, 'r');

if strcmpi(strategy,'addblank')
    % Add a blank signal before the late signal
    if toffset > 0  % Sig A is ahead of Sig B
        toffset_sample = round(toffset*SigB.srate);
        sigBsynch_data = zeros(SigB.nchan, SigB.npnts+toffset_sample);
        SigBsynch = s_newsig(sigBsynch_data, SigB.channames, SigB.srate, SigB.type, SigB.tmin, ...
            SigB.tmax+toffset, SigB.filename, SigB.filepath, SigB.montage, ...
            [SigB.desc,'-sync'], SigB.israw, SigB.id, -1, SigB.badchannelpos, SigB.badepochpos);
        SigBsynch.data(:, toffset_sample+1:end) = SigB.data;
        SigAsynch = SigA;
    elseif toffset < 0  % Sig B is ahead of Sig A
        toffset_sample = round(abs(toffset)*SigA.srate);
        sigAsynch_data = zeros(SigA.nchan, SigA.npnts+toffset_sample);
        SigAsynch = s_newsig(sigAsynch_data, SigA.channames, SigA.srate, SigA.type, SigA.tmin, ...
            SigA.tmax+toffset, SigA.filename, SigA.filepath, SigA.montage, ...
            [SigA.desc,'-sync'], SigA.israw, SigA.id, -1, SigA.badchannelpos, SigA.badepochpos);
        SigAsynch.data(:, toffset_sample+1:end) = SigA.data;
        SigBsynch = SigB;
    else    % No time offset
        SigAsynch = SigA;
        SigBsynch = SigB;
    end
elseif strcmpi(strategy,'cut')
    % Cut the beggining of the ahead signal
        if toffset > 0  % Sig A is ahead of Sig B
        toffset_sample = round(toffset*SigA.srate);
        sigAsynch_data = SigA.data(:,toffset_sample:end);
        SigAsynch = s_newsig(sigAsynch_data, SigA.channames, SigA.srate, SigA.type, SigA.tmin, ...
            SigA.tmax-toffset, SigA.filename, SigA.filepath, SigA.montage, ...
            [SigA.desc,'-sync'], SigA.israw, SigA.id, -1, SigA.badchannelpos, SigA.badepochpos);
        SigBsynch = SigB;
    elseif toffset < 0  % Sig B is ahead of Sig A
        SigAsynch = SigA;
        toffset_sample = round(abs(toffset)*SigB.srate);
        sigBsynch_data = SigB.data(:,toffset_sample:end);
        SigBsynch = s_newsig(sigBsynch_data, SigB.channames, SigB.srate, SigB.type, SigB.tmin, ...
            SigB.tmax-toffset, SigB.filename, SigB.filepath, SigB.montage, ...
            [SigB.desc,'-sync'], SigB.israw, SigB.id, -1, SigB.badchannelpos, SigB.badepochpos);
    else    % No time offset
        SigAsynch = SigA;
        SigBsynch = SigB;
        end
else
    error('Wrong strategy argument - Must be ''AddBlank'' or ''Cut''');
end
    
end


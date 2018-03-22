function HFOEvents = ripplelab_findHFOxSTE(xFiltered,params,Fs)
%   f_findHFOxSTF.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com
%   Modified by:
%   Martin Deudon
%   for integration in micMac (2016)

% Modification:
% - The input signal (first argument) must be previously filtered 
% - no epoch arguments

%% Variable declarations
% p_HFOWaitFigure(st_WaitOutput,...
%                 'MethPatch',0)
            
% m_Data          = [];
% load(pstr_SignalPath)
% pv_Signal       = m_Data(:,ps_SignalIdx);
% clear m_Data

% v_Freqs         = [params.s_FreqIni params.s_FreqEnd];% Filter freqs
s_Window        = params.rmsWinTimeSec;             	% RMS window time (s)
s_RMSThresSD    = params.rmsThreshSD;                   % Threshold for RMS in standard deviation
s_MinWind       = params.hfoMinTimeSec;                 % Min window time for an HFO (s)
s_MinTime       = params.minGapTimeSec;                 % Min Distance time Betwen two HFO candidates
s_NumOscMin     = params.minNumPeaks;                   % Minimum oscillations per interval
s_BPThresh      = params.peakThreshSD;               	% Threshold for finding peaks
% s_EpochLength   = params.epochTime;                     % Cycle Time

v_SigFilt       = xFiltered; 

%% RMS Calculus

s_Window        = round(s_Window * Fs);
if mod(s_Window, 2) == 0
    s_Window = s_Window + 1;
end
v_Temp                      = v_SigFilt.^2;
v_Temp                      = filter(ones(1,s_Window),1,v_Temp)./s_Window;
v_RMS                       = zeros(numel(v_Temp), 1);
v_RMS(1:end - ceil(s_Window / 2) + 1) = v_Temp(ceil(s_Window / 2):end);
v_RMS                       = sqrt(v_RMS);

%% Thresholding
s_MinWind       = round(s_MinWind * Fs);
s_MinTime       = round(s_MinTime * Fs);
% s_EpochLength   = round(s_EpochLength * Fs);
% v_EpochTemp     = (1:s_EpochLength:length(xFiltered))';
% if v_EpochTemp(end) < length(xFiltered)
%     v_EpochTemp(end+1)  = length(xFiltered);
% end
m_EpochLims     = [1, length(xFiltered)];       % modification

% m_EpochLims     = [v_EpochTemp(1:end-1) v_EpochTemp(2:end)-1];
% s_Epochs        = size(m_EpochLims,1);

HFOEvents = [];  

for ii = 1:size(m_EpochLims,1)

    v_Window        = zeros(numel(v_RMS),1);
    v_Window(m_EpochLims(ii,1):m_EpochLims(ii,2)) = 1;

    v_RMSEpoch      = v_RMS.*v_Window;
    v_RMSInterval   = v_RMS(m_EpochLims(ii,1):m_EpochLims(ii,2));
    v_EpochFilt     = v_SigFilt(m_EpochLims(ii,1):m_EpochLims(ii,2));

    v_RMSThres      = v_RMSEpoch > ...
                        (mean(v_RMSInterval)+ ...
                            s_RMSThresSD*std(v_RMSInterval));

    if isempty(numel(find(v_RMSThres)))
        continue
    end
    
    v_WindThres     = [0;v_RMSThres;0];
    v_WindJumps     = diff(v_WindThres);
    v_WindJumUp     = find(v_WindJumps==1);
    v_WindJumDown   = find(v_WindJumps==-1);
    v_WinDist       = v_WindJumDown - v_WindJumUp;

    v_WindIni       = v_WindJumUp(v_WinDist > s_MinWind);  
    v_WindEnd       = v_WindJumDown(v_WinDist > s_MinWind)-1;

    if isempty(v_WindIni)
        continue
    end

    while 1
        v_NextIni   = v_WindIni(2:end);
        v_LastEnd   = v_WindEnd(1:end-1);
        v_WinIdx	= (v_NextIni - v_LastEnd) < s_MinTime;
        if sum(v_WinIdx)==0
            break
        end
        v_NewEnd    = v_WindEnd(2:end);

        v_LastEnd(v_WinIdx) = v_NewEnd(v_WinIdx);
        v_WindEnd(1:end-1)  = v_LastEnd;

        v_Idx       = diff([0;v_WindEnd])~=0;
        v_WindIni   = v_WindIni(v_Idx);
        v_WindEnd   = v_WindEnd(v_Idx);        
    end

    m_WindIntervals = [v_WindIni v_WindEnd];

    s_Count             = 1;
    m_WindSelect        = zeros(size(m_WindIntervals));

    s_Threshold         = mean(abs(v_EpochFilt)) + ...
                                    s_BPThresh.*std(abs(v_EpochFilt));
    s_TotalWindInterv	= size(m_WindIntervals,1);


    for jj=1:s_TotalWindInterv

        v_Temp          = abs(v_SigFilt(m_WindIntervals(jj,1):m_WindIntervals(jj,2)));

        if numel(v_Temp) < 3
            continue
        end

        s_NumPeaks      = findpeaks(v_Temp,'minpeakheight',s_Threshold);

        if isempty(s_NumPeaks) || length(s_NumPeaks) < s_NumOscMin
            continue;
        end

        m_WindSelect(s_Count,:) = [m_WindIntervals(jj,1), m_WindIntervals(jj,2)];
        s_Count                 = s_Count + 1;

    end

    if any(m_WindSelect(:))
        HFOEvents     = vertcat(HFOEvents, m_WindSelect(1:s_Count-1,:)); %#ok<AGROW>
    end

end

 
end
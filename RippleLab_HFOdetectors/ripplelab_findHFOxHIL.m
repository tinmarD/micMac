function m_HFOEvents = ripplelab_findHFOxHIL(xFiltered,params,Fs)
                                            
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


%% Variable declarations

% v_Freqs         = [st_DatA.s_FreqIni st_DatA.s_FreqEnd];% Filter freqs
s_SDThres   	= params.threshold;              	% Threshold in standard deviation
s_MinWind       = params.hfoMinTimSec;              % Min window time for an HFO (ms)
% s_EpochLength   = st_DatA.s_EpochTime;         	% Cycle Time


%% Preprocessing Filter            
v_SigFilt       = xFiltered(:);


%% Hilbert transform Calculus
v_SigFilt       = abs(hilbert(v_SigFilt));
            

%% Thresholding

s_MinWind       = round(s_MinWind * Fs);

m_EpochLims     = [1, length(xFiltered)];

m_HFOEvents = [];  

for ii = 1:size(m_EpochLims,1)

    v_EpochFilt     = v_SigFilt(m_EpochLims(ii,1):m_EpochLims(ii,2));

    v_WinThres      = v_EpochFilt > ...
                        (mean(v_EpochFilt)+ s_SDThres*std(v_EpochFilt));

    if isempty(numel(find(v_WinThres)))
        continue
    end

    v_WindThres     = [0;v_WinThres;0];
    v_WindJumps     = diff(v_WindThres);
    v_WindJumUp     = find(v_WindJumps==1);
    v_WindJumDown   = find(v_WindJumps==-1)-1;        
    v_WinDist       = v_WindJumDown - v_WindJumUp;

    v_DistSelect    = (v_WinDist > s_MinWind);
    v_WindJumUp     = v_WindJumUp(v_DistSelect);  
    v_WindJumDown   = v_WindJumDown(v_DistSelect)-1;

    m_WindSelect	= [v_WindJumUp v_WindJumDown] + m_EpochLims(ii,1)-1;

    if any(m_WindSelect(:))
        m_HFOEvents     = vertcat(m_HFOEvents,m_WindSelect); %#ok<AGROW>
    end


end

end
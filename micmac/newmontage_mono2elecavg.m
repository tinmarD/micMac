function [VI, ALLWIN, ALLSIG, sigid] = newmontage_mono2elecavg(VI, ALLWIN, ALLSIG, Sig, avgMethod)
%[VI, ALLWIN, ALLSIG, sigid] = NEWMONTAGE_MONO2AVG(VI, ALLWIN, ALLSIG, Sig, avgMethod)
%   Create new signal with electrode average montage from signal with monopolar
%   montage. Average is computed for each electrode and substracted from
%   the electrode channels. 

chanNames                       = Sig.channamesnoeeg;
[electrodePos,electrodeNames]   = getelectrodepos(Sig);
%- Remove only eeg electrodes
electrodePosEEG     = electrodePos(Sig.eegchannelind);
nElectrodeEEG       = length(unique(electrodePosEEG));
nElectrodeALL       = length(unique(electrodePos));
electrodeEEGNum     = unique(electrodePosEEG);
electrodeNoEEGNum   = setdiff(unique(electrodePos),electrodeEEGNum);

dataAvg             = cell(nElectrodeALL,1);
chanNamesAvg        = cell(nElectrodeALL,1);
eegChannelInd       = cell(nElectrodeALL,1);

%- Average estimation, accross all good eeg channels:
goodEegChannelInd   = Sig.eegchannelind;
goodEegChannelInd(Sig.badchannelpos) = 0;
elAvg               = zeros(nElectrodeEEG,Sig.npnts);
for i=1:nElectrodeEEG
    elecNum_i               = electrodeEEGNum(i);
    goodChannelElectrode_i  = electrodePos==elecNum_i & goodEegChannelInd;
    if strcmp(avgMethod,'mean')
        elAvg(i,:)  = mean(Sig.data(goodChannelElectrode_i,:));
    elseif strcmp(avgMethod,'median')
        elAvg(i,:)  = median(Sig.data(goodChannelElectrode_i,:));
    else 
        error(['Unknown average estimation method : ',avgMethod]);
    end
end

%- EEG channels
for i=1:nElectrodeEEG
    elecNum_i       = electrodeEEGNum(i);       % Number of the electrode
    elecName        = electrodeNames{elecNum_i};% Electrode Name
    elecChanInd_i   = electrodePos==elecNum_i;  % Indices of the channels belonging to this electrode 
    elecChanPos_i   = find(elecChanInd_i);      % Position
    nChan_i         = sum(elecChanInd_i);       % Number of channels in this electrode
    chanNum_i       = regexp(chanNames(elecChanInd_i),'\d+','match');
    chanNum_i       = str2double([chanNum_i{:}]);   % Vector of the channel numbers for this electrode
    if sum(isnan(chanNum_i))~=0; error('Error in the detection of the channel numbers'); end;
    dataEl_i            = zeros(nChan_i,Sig.npnts);
    chanNamesAvg_i      = cell(1,nChan_i);
    for j=1:nChan_i
        dataEl_i(j,:)     	= Sig.data(elecChanPos_i(j),:)-elAvg(i,:);
        chanNamesAvg_i{j}   = ['EEG ',elecName,num2str(chanNum_i(j)),'_elAvg'];
    end
    dataAvg{elecNum_i}      = dataEl_i;
    chanNamesAvg{elecNum_i} = chanNamesAvg_i;
    eegChannelInd{elecNum_i}= ones(1,nChan_i);
end

%- Non-EEG channels 
for i=1:nElectrodeALL-nElectrodeEEG
    elecNum_i       = electrodeNoEEGNum(i);
    elecChanInd_i   = electrodePos==elecNum_i;  % Indices of the channels belonging to this electrode 
    elecChanPos_i   = find(elecChanInd_i);      % Position
    nChan_i         = sum(elecChanInd_i);       % Number of channels in this electrode
    %- Recopy the channels
    dataEl_i        = zeros(nChan_i,Sig.npnts);
    chanNamesAvg_i  = cell(1,nChan_i);
    for j=1:nChan_i
        dataEl_i(j,:)      	= Sig.data(elecChanPos_i(j),:);
        chanNamesAvg_i{j}   = chanNames{elecChanPos_i(j)};
    end    
    dataAvg{elecNum_i}      = dataEl_i;
    chanNamesAvg{elecNum_i} = chanNamesAvg_i;
    eegChannelInd{elecNum_i}    = zeros(1,nChan_i);
end

dataAvgMat      = cat(1,dataAvg{:});
chanNamesAvg    = [chanNamesAvg{:}];

%- Create new signal structure
[VI, ALLWIN, ALLSIG, sigid] = addsignal(VI, ALLWIN, ALLSIG, dataAvgMat, ...
    chanNamesAvg, Sig.srate, Sig.type, Sig.tmin, Sig.tmax,  ' ', ' ', 'electrode average', [Sig.desc,'_elAvg'], ...
    Sig.israw, -1, Sig.badchannelpos, Sig.badepochpos);

%- Add channcorr
[~,SigMonoInd]  = getsignal(ALLSIG,'sigid',Sig.id);
SigInPos        = find(SigMonoInd);
SigOutPos    	= length(ALLSIG);
chancorr        = repmat((1:Sig.nchan)',1,2);
VI              = addchancorr(VI,SigInPos,SigOutPos,chancorr,chancorr);
% VI.chancorr{SigInPos,SigOutPos} = chancorr;
% VI.chancorr{SigOutPos,SigInPos} = chancorr;


end

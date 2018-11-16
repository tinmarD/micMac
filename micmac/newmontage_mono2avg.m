function [VI, ALLWIN, ALLSIG, sigid] = newmontage_mono2avg(VI, ALLWIN, ALLSIG, Sig, avgMethod)
%[VI, ALLWIN, ALLSIG, sigid] = NEWMONTAGE_MONO2AVG(VI, ALLWIN, ALLSIG, Sig, avgMethod)
%   Create new signal with average montage from signal with monopolar
%   montage. Average is computed across all channels either using the mean
%   or the median (avgMethod)

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
if strcmp(avgMethod,'mean')
    avg     = mean(Sig.data(goodEegChannelInd,:));
elseif strcmp(avgMethod,'median')
    avg     = median(Sig.data(goodEegChannelInd,:));
else 
    error(['Unknown average estimation method : ',avgMethod]);
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
        dataEl_i(j,:)     	= Sig.data(elecChanPos_i(j),:)-avg;
        chanNamesAvg_i{j}   = ['EEG ',elecName,num2str(chanNum_i(j)),'_avg'];
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
    dataEl_i        = zeros(nChan_i-1,Sig.npnts);
    chanNamesAvg_i  = cell(1,nChan_i);
    for j=1:nChan_i
        dataEl_i(j,:)           = Sig.data(elecChanPos_i(j),:);
        chanNamesAvg_i{j}   = chanNames{elecChanPos_i(j)};
    end    
    dataAvg{elecNum_i}      = dataEl_i;
    chanNamesAvg{elecNum_i} = chanNamesAvg_i;
    eegChannelInd{elecNum_i}    = zeros(1,nChan_i);
end

dataAvgMat      = cat(1,dataAvg{:});
chanNamesAvg    = [chanNamesAvg{:}];

%- Create bipolar signal structure
[VI, ALLWIN, ALLSIG, sigid] = addsignal(VI, ALLWIN, ALLSIG, dataAvgMat, ...
    chanNamesAvg, Sig.srate, Sig.type, Sig.tmin, Sig.tmax, ' ', ' ', 'average', [Sig.desc,'_avg'], ...
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

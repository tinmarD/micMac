function [VI, ALLWIN, ALLSIG, sigid] = newmontage_mono2bi(VI, ALLWIN, ALLSIG, Sig)
%[VI, ALLWIN, ALLSIG, sigid] = NEWMONTAGE_MONO2BI(VI, ALLWIN, ALLSIG, Sig)
%   Create new signal with bipolar montage from signal with monopolar
%   montage

chanNames                       = Sig.channamesnoeeg;
[electrodePos,electrodeNames]   = getelectrodepos(Sig);
%- Remove only eeg electrodes
electrodePosEEG     = electrodePos(Sig.eegchannelind);
nElectrodeEEG       = length(unique(electrodePosEEG));
nElectrodeALL       = length(unique(electrodePos));
electrodeEEGNum     = unique(electrodePosEEG);
electrodeNoEEGNum   = setdiff(unique(electrodePos),electrodeEEGNum);

dataBipolar         = cell(nElectrodeALL,1);
chanNamesBipolar    = cell(nElectrodeALL,1);
eegChannelInd       = cell(nElectrodeALL,1);

%- EEG channels
for i=1:nElectrodeEEG
    elecNum_i       = electrodeEEGNum(i);       % Number of the electrode
    elecName        = electrodeNames{elecNum_i};% Electrode Name
    elecChanInd_i   = electrodePos==elecNum_i;  % Indices of the channels belonging to this electrode 
    elecChanInd_i(Sig.badchannelpos) = 0;       % remove bad channels
    elecChanPos_i   = find(elecChanInd_i);      % Position   
    nChan_i         = sum(elecChanInd_i);       % Number of channels in this electrode
    chanNum_i       = regexp(chanNames(elecChanInd_i),'\d+','match');
    chanNum_i       = str2double([chanNum_i{:}]);   % Vector of the channel numbers for this electrode
    if sum(isnan(chanNum_i))~=0; error('Error in the detection of the channel numbers'); end;
    dataEl_i            = zeros(nChan_i-1,Sig.npnts);
    chanNamesBipolar_i  = cell(1,nChan_i-1);
    for j=1:nChan_i-1
        dataEl_i(j,:)           = Sig.data(elecChanPos_i(j+1),:)-Sig.data(elecChanPos_i(j),:);
        chanNamesBipolar_i{j}   = ['EEG ',elecName,num2str(chanNum_i(j)),'-',elecName,num2str(chanNum_i(j+1))];
    end
    dataBipolar{elecNum_i}      = dataEl_i;
    chanNamesBipolar{elecNum_i} = chanNamesBipolar_i;
    eegChannelInd{elecNum_i}    = ones(1,nChan_i-1);
end

%- Non-EEG channels 
for i=1:nElectrodeALL-nElectrodeEEG
    elecNum_i       = electrodeNoEEGNum(i);
    elecChanInd_i   = electrodePos==elecNum_i;  % Indices of the channels belonging to this electrode 
    elecChanPos_i   = find(elecChanInd_i);      % Position
    nChan_i         = sum(elecChanInd_i);       % Number of channels in this electrode
    %- Recopy the channels
    dataEl_i        = zeros(nChan_i-1,Sig.npnts);
    chanNamesBipolar_i  = cell(1,nChan_i);
    for j=1:nChan_i
        dataEl_i(j,:)           = Sig.data(elecChanPos_i(j),:);
        chanNamesBipolar_i{j}   = chanNames{elecChanPos_i(j)};
    end    
    dataBipolar{elecNum_i}      = dataEl_i;
    chanNamesBipolar{elecNum_i} = chanNamesBipolar_i;
    eegChannelInd{elecNum_i}    = zeros(1,nChan_i);
end

dataBipolarMat      = cat(1,dataBipolar{:});
chanNamesBipolar    = [chanNamesBipolar{:}];

%- Create bipolar signal structure
[VI, ALLWIN, ALLSIG, sigid] = addsignal(VI, ALLWIN, ALLSIG, dataBipolarMat, ...
    chanNamesBipolar, Sig.srate, Sig.type, ' ', ' ', 'bipolar', [Sig.desc,'-bipolar'], ...
    Sig.israw, -1, []);


%- Create channel correlations
% nBadChannels        = length(Sig.badchannelpos);
nChanMono           = Sig.nchan;
nChanBi             = Sig.nchan-nElectrodeEEG;
chancorrMono2Bi     = zeros(nChanMono,2);
chancorrBi2Mono     = zeros(nChanBi,2);
elPosMono           = getelectrodepos(Sig);
elPosBi             = getelectrodepos(ALLSIG(end));
elNumbers           = unique(elPosMono);
% badMonoEl           = 0;
for i=1:nElectrodeEEG
    elNum_i         = elNumbers(i); 
    elChanMono_i    = find(elPosMono==elNum_i);
    elChanMono_i    = setdiff(elChanMono_i,Sig.badchannelpos);
    if isempty(elChanMono_i)
%         badMonoEl = badMonoEl + 1;
        continue;
    end
    elChanBi_i      = find(elPosBi==(elNum_i));
    for j=1:length(elChanMono_i)
        if j==1
            chancorrMono2Bi(elChanMono_i(j),:)  = [elChanBi_i(j),elChanBi_i(j)];
            chancorrBi2Mono(elChanBi_i(j),:)    = [elChanMono_i(j),elChanMono_i(min(j+1, length(elChanMono_i)))];
        elseif j==length(elChanMono_i)
            chancorrMono2Bi(elChanMono_i(j),:) = [elChanBi_i(j-1),elChanBi_i(j-1)];
        else
            chancorrMono2Bi(elChanMono_i(j),:) = [elChanBi_i(j-1),elChanBi_i(j)];
            chancorrBi2Mono(elChanBi_i(j),:)   = [elChanMono_i(j),elChanMono_i(j+1)];
        end
    end       
end
for i=1:length(electrodeNoEEGNum);
    elNum_i = electrodeNoEEGNum(i);
    elChanMono_i    = find(elPosMono==elNum_i);
    elChanBi_i      = find(elPosBi==elNum_i);
    for j=1:length(elChanMono_i)
        chancorrMono2Bi(elChanMono_i(j),:) = [elChanBi_i(j),elChanBi_i(j)];
        chancorrBi2Mono(elChanBi_i(j),:)   = [elChanMono_i(j),elChanMono_i(j)];
    end
end

[~,SigMonoInd]  = getsignal(ALLSIG,'sigid',Sig.id);
SigMonoPos      = find(SigMonoInd);
SigBiPos        = length(ALLSIG);

VI              = addchancorr(VI,SigMonoPos,SigBiPos,chancorrMono2Bi,chancorrBi2Mono);
% VI.chancorr{SigMonoPos,SigBiPos} = chancorrMono2Bi;
% VI.chancorr{SigBiPos,SigMonoPos} = chancorrBi2Mono;

end




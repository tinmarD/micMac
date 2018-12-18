function EEG = sig2eeg(Sig)
% EEG = SIG2EEG (SIG)
%   Convert a micMac Sig structure to EEGLAB EEG structure
%   Can only convert micMac signals of type ''continuous'' or ''epoch''
% 
% INPUTS : 
%   - Sig           : micMac Sig structure
%
% OUTPUTS : 
%   - EEG           : EEGLAB EEG structure 
%
% See also eeg2sig

if strcmpi(Sig.type,'continuous') || strcmpi(Sig.type,'epoch')
    EEG         = eeg_emptyset();
    EEG.data    = Sig.data;
    EEG.srate   = Sig.srate;
    EEG.nbchan  = Sig.nchan;
    EEG.pnts    = Sig.npnts / Sig.ntrials;
    EEG.trials  = Sig.ntrials;
    EEG.xmin    = Sig.tmin;
    EEG.xmax    = Sig.tmax;        
    EEG.filename= Sig.filename;
    EEG.filepath= Sig.filepath;
    EEG.setname = Sig.desc;
    if strcmpi(Sig.type,'epoch')
        EEG.data = reshape(Sig.data,[EEG.nbchan, EEG.pnts, EEG.trials]);
        EEG.xmax = Sig.tmax / Sig.ntrials;       
    end
    EEG = eeg_checkset(EEG);
    chanlocs = struct('labels','','ref','','theta',[],'radius',[],...
            'X',[],'Y',[],'Z',[],'sph_theta',[],'sph_phi',[],'sph_radius',[],'type','','urchan',[]);
    chanlocs(Sig.nchan).labels = '';
    for i=1:Sig.nchan
        chanlocs(i) = struct('labels',Sig.channames{i},'ref','','theta',[],'radius',[],...
            'X',[],'Y',[],'Z',[],'sph_theta',[],'sph_phi',[],'sph_radius',[],'type','','urchan',[]);
    end
    EEG.chanlocs = chanlocs;
else
    error(['Cannot convert to an EEGLAB structure a micMac signal of type ',Sig.type]);
end

end


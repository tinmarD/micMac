function EEG = sig2eeg( Sig )
% EEG = SIG2EEG (SIG)
%   Convert a micMac Sig structure to EEGLAB EEG structure
% 
% INPUTS : 
%   - Sig           : micMac Sig structure
%
% OUTPUTS : 
%   - EEG           : EEGLAB EEG structure 
%
% See also eeg2sig


EEG         = eeg_emptyset();
EEG.data    = Sig.data;
EEG.srate   = Sig.srate;
EEG.nbchan  = Sig.nchan;
EEG.pnts    = Sig.npnts;
EEG.xmin    = 0;
EEG.xmax    = Sig.tmax;
EEG.filename= Sig.filename;
EEG.filepath= Sig.filepath;
EEG.setname = Sig.desc;
EEG = eeg_checkset(EEG);
chanlocs = struct('labels','','ref','','theta',[],'radius',[],...
        'X',[],'Y',[],'Z',[],'sph_theta',[],'sph_phi',[],'sph_radius',[],'type','','urchan',[]);
chanlocs(Sig.nchan).labels = '';
for i=1:Sig.nchan
    chanlocs(i) = struct('labels',Sig.channames{i},'ref','','theta',[],'radius',[],...
        'X',[],'Y',[],'Z',[],'sph_theta',[],'sph_phi',[],'sph_radius',[],'type','','urchan',[]);
end
EEG.chanlocs = chanlocs;

end


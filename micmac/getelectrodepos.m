function [electrodePos, electrodeNames] = getelectrodepos (Sig)
%[electrodePos, electrodeNames] = GETELECTRODEPOS (Sig) 
% Returns for each channel the electrode number. Return a vector of length
% the number of channel. 
%
% Electrode names must consist of alphabetic characters and ' 
% Authorized characters: a-zA-Z'
%
% INPUTS :
%   - Sig               : micMac signal structure
% 
% OUTPUTS : 
%   - electrodePos      : vector [1,nChan] containing for each channel the 
%                         electrode position of the channel
%   - electrodeNames    : vector [1,nChan] containing for each channel the 
%                         electrode name of the channel
%

chanNames       = regexp(Sig.channamesnoeeg,'[a-zA-Z'']+','match','once');

electrodeNames  = unique(chanNames,'stable');
electrodeNames(strcmp(electrodeNames,'avg'))    = [];
electrodeNames(strcmp(electrodeNames,'elAvg'))  = [];

electrodePos    = zeros(1,Sig.nchan);
for i=1:Sig.nchan
    electrodeName_i = regexp(Sig.channamesnoeeg(i),'[a-zA-Z'']+','match','once');
    if isempty(electrodeName_i); error('Could not determine electrode name'); end;
%     electrodeName_i = unique([electrodeName_i{:}],'stable'); 
%     if length(electrodeName_i)>1; electrodeName_i=electrodeName_i{1}; end; % Case with _avg
    electrodePos_i  = find(strcmp(electrodeName_i,electrodeNames));
    if isempty(electrodePos_i);  error('Could not determine electrode name'); end;
    electrodePos(i) = electrodePos_i;
end


end


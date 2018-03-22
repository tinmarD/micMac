function [outMont, inMontPos] = getpossiblemontages (Sig,elType,inMont)
%[outMont, inMontPos] = GETPOSSIBLEMONTAGES (elType,inMont)
% Returns the possibles output montages given the input montage and signal
%
% INPUTS : 
%   - Sig               : Input signal
%   - elType            : Electrode type ('depth' or 'tetrode')
%   - inMont            : Input montage 
%
% OUTPUTS : 
%   - outMont           : Output possible montages
%   - inMontPos         : Position of input montage in the list of all
%                         possible montages

montages    = vi_defaultval('montages');
elTypes     = vi_defaultval('electrode_types');
%- Internal call 
if nargin==0
    Sig = [];
    elType = elTypes{get(findobj(gcbf,'tag','eltypepop'),'value')};
    inMont = montages{get(findobj(gcbf,'tag','inMontPop'),'value')};
end


%-Check input montage
if ~ismember(inMont,montages) && ~isempty(Sig)
    inMont =  fastif(isempty(regexp(Sig.channames{1},'-','once')),'monopolar','bipolar');
end
inMontPos = find(ismember(montages,inMont));

%- Determine the possible output montages
if strcmp(elType,'depth')
    switch inMont
        case 'monopolar'
            outMont = {'bipolar','average','electrode-average'};
        case 'bipolar'
            outMont = {'average','electrode-average'};
        case 'average'
            outMont = [];
        otherwise 
            warning(['Unknown montage : ',inMont]);
            outMont = [];
    end
elseif strcmp(elType,'tetrode')
    outMont = [];
else
    error(['Unknown electrode type : ',elType]);
end



end


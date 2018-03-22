function [ View ] = s_newview(viewId, sigId, domain, viewParams, gain)
% View = S_NEWVIEW (viewid, sigid, domain, viewparams, gain)
% Gain is initalized at 1 for both visualisation modes
% INPUTS:
%   - viewId        : View's Id
%   - sigId         : Id of the signal visualized
%   - domain        : View's domain - can be 't','f','tf'
%   - viewParams    : View parameters
%   - gain          : View gain (Optional)
% 
%
% OUTPUTS:
%   - View          : View structure
%
% View Structure fields:
%       id          : View's Id
%       sigid       : Id of the signal visualized
%       domain      : View's domain - can be 't','f','tf'
%       gain        : Gain for each visualisation mode. [1,2] vector
%       scale       : Scale in uV/cm. Linked to gain and axes dimensions. [1,2] vector
%       couleur     : View color (not used for 'tf' views)
%       params      : View parameters
%
% See also : addview

View.id     = viewId;
View.sigid  = sigId;
View.domain = domain;                                           % 't','f','tf'   (time,frequency(fft),time-frequency)
if nargin<5
    View.gain   = ones(1,length(vi_defaultval('visumode_names')));  % Init gain a 1
else
    View.gain   = gain;
end
View.scale  = [NaN,NaN];                                        % Scale is related to gain and axes dimensions
couleurs    = vi_graphics('plotcolors');
View.couleur= couleurs(max(1,rem(viewId,size(couleurs,1))),:);
View.params = viewParams;

end


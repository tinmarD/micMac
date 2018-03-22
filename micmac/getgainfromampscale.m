function [gain,uvPerCmStr] = getgainfromampscale(uvPerCm, visuMode, axHandle)
% [gain] = GETGAINFROM(uvPerCm, visuMode)
%   or     getgainfromampscale(uvPerCm, visuMode, axHandle)
%   Convert the amplitude scale in uV/cm to gain
%
% INPUTS : 
%   - uvPerCm       : amplitude scale in uV/cm
%   - visuMode      : Window's visualisation mode (stacked or spaced)
%   - axHandle      : axis handle (optional)
% 
% OUTPUTS : 
%   - gain          : gain 
%   - uvPerCmStr    : amplitude scale in uV/cm string 
%
% See also getampscalefromgain

if nargin==2
    axHandle = gca;
end

axisUnits       = get(axHandle,'units');
set(axHandle,'units','centimeters');
axisPosition    = get(axHandle,'position');
axisHeightCm    = axisPosition(4);
set(axHandle,'units',axisUnits);

if visuMode == 1 % stacked mode
    gain    = log((diff(ylim)+axisHeightCm*uvPerCm)/(axisHeightCm*uvPerCm));
elseif visuMode == 2% spaced mode
    gain    = log((vi_defaultval('unity_height')+axisHeightCm*uvPerCm)/(axisHeightCm*uvPerCm));
end

if uvPerCm<1
    uvPerCmStr = sprintf('%.2f',uvPerCm);
elseif uvPerCm<10
    uvPerCmStr = sprintf('%.1f',uvPerCm);
else
    uvPerCmStr = sprintf('%.0f',uvPerCm);
end


end


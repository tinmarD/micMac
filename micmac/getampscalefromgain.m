function [uvPerCm, uvPerCmStr] = getampscalefromgain(gain, visuMode, axfocus)
%[uvPerCm, uvPerCmStr] = getampscalefromgain(gain, visuMode, axfocus)
%   Convert the gain to amplitude scale in uV/cm
%
% INPUTS :
%   - gain              : gain
%   - visuMode          : Window's visualisation mode (stacked or spaced)
%   - axFocus           : axis handle of the focused axis
%
% OUTPUTS : 
%   - uvPerCm           : amplitude scale in uV/cm
%   - uvPerCmStr        : amplitude scale in uV/cm string 
%
% See also getgainfromampscale

if ~isempty(axfocus)
    try axes(axfocus); catch; end;
end

gain = median([vi_defaultval('gain_min'),gain,vi_defaultval('gain_max')]);
    
if visuMode == 1 % stacked mode
    axisAmpRange    = diff(ylim)/(-1+exp(gain));
elseif visuMode == 2% spaced mode
    axisAmpRange    = diff(ylim);
end
axisUnits       = get(gca,'units');
set(gca,'units','centimeters');
axisPosition    = get(gca,'position');
axisHeightCm    = axisPosition(4);
set(gca,'units',axisUnits);
uvPerCm         = axisAmpRange/axisHeightCm;

if uvPerCm<1
    uvPerCmStr = sprintf('%.2f',uvPerCm);
elseif uvPerCm<10
    uvPerCmStr = sprintf('%.1f',uvPerCm);
else
    uvPerCmStr = sprintf('%.0f',uvPerCm);
end

end


function [SC] = getwhitenedscalogram(coeffs, scales)
%[SC] = GETWHITENEDSCALOGRAM (coeffs, scales)
% Wavelet coefficients normalization in L². Weighting function is 1/a
% and not 1/sqrt(a))
% See Time-frequency strategies for increasing high frequency oscillation 
% detectability in intracerebral EEG - Roehri, Bénar & al (2016)
%
% INPUTS :
%   - coeffs            : CWT coefficients
%   - scales            : CWT scales
%
% OUTPUTS :
%   - SC                : Wavelet scalogram

%- Normalize CWT coeffs in L² (weighting function is 1/a and not 1/sqrt(a))
coeffs          = coeffs./repmat(sqrt(scales(:)),1,size(coeffs,2));

%% Normalize the data
nScales         = length(scales);
%- Real part
coeffNormRe     = getnormalizedcoeff(real(coeffs),nScales);
%- Imaginary part
if ~isreal(coeffs)
    coeffNormIm = getnormalizedcoeff(imag(coeffs),nScales);
    %- Re-assemble real and imaginary part
    coeffNorm   = coeffNormRe+1i.*coeffNormIm;
else
    coeffNorm   = coeffNormRe;
end

SC               = abs(coeffNorm.*coeffNorm);
end


function [coeffNorm] = getnormalizedcoeff(coeff, nScales)
coeffNorm = zeros(size(coeff));
for i=1:nScales
    coeff_i = coeff(i,:);
    % Get Q1 (quartile 1) and Q3 (quartile 3)
    coeffSorted_i   = sort(coeff_i);
    quart1          = coeffSorted_i(ceil(length(coeff_i)*0.25));
    quart3          = coeffSorted_i(ceil(length(coeff_i)*0.75));
    % Inter-quartile range
    iqr             = quart3-quart1; 
    %- Select data:  Q1-1.5*iqr < data < Q3+1.5*iqr
    firstValSel     = max(coeffSorted_i(1),round(quart1-1.5*iqr));
    lastValSel      = min(coeffSorted_i(end),quart3+1.5*iqr);
    coeffSel_i      = coeffSorted_i(coeffSorted_i>firstValSel & coeffSorted_i<lastValSel);
    %- Gaussian fit on hist of selected data
%     [hist_i,bins_i] = hist(coeffSel_i,30);
%     try
% %         gaussFit 	= fit(bins_i(:),hist_i(:),'gauss1','TolX',1E-2);
%         gaussFit 	= fit(bins_i(:),hist_i(:),'gauss1');
%         mean_i  	= gaussFit.b1;
%         std_i     	= gaussFit.c1;
%     catch 
%         warning('Could not fit gaussian on data');
        mean_i      = mean(coeffSel_i);
        std_i       = std(coeffSel_i);
%     end
    %- Normalize data
    coeffNorm(i,:)  = (coeff_i-mean_i)./std_i;
%       figure;
%     [h, b] = hist(coeffSorted_i, 30);
%     bar(b, h); hold on;
%     plot([quart1, quart1], ylim, 'k');
%     plot([quart3, quart3], ylim, 'k');
  
%    
end
end


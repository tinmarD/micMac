function [dataout] = op_kteo (datain, k, smoothing, smoothingnorm)
% [dataout] = op_kteo (datain, k) - k-Teager Energy Operator
%   Inputs : 
%       datain          : (N*M) data matrix of N channels of M samples
%       k               : value of k parameter
%       smoothing       : Smooth the output signal (4*k+1 Hamming Window)
%           (default 1) 
%       smoothingnorm   : Normalize the smoothing window - (default 1)

if nargin==2
    smoothing       = 1;
    smoothingnorm   = 1;
elseif nargin==3
    smoothingnorm   = 1;
end

nchan   = size (datain,1);
dataout = zeros(nchan,size(datain,2));

for i=1:nchan
    xshiftl = [datain(i,1+k:end),zeros(1,k)];
    xshiftr = [zeros(1,k),datain(i,(1:end-k))];

    dataout(i,:) = datain(i,:).^2 - xshiftl.*xshiftr;
    dataout(i,[1:k,end-k+1:end]) = 0;
    
    if smoothing
        % Compute the coefficients of the smoothing window
        hk = hamming(4*k+1);
        if smoothingnorm
            % Normalize them
            hk = hk./sqrt(3*sum(hk.^2)+sum(hk).^2);
        end
        % Apply the smoothing window
        dataout(i,:) = conv (dataout(i,:), hk, 'same');
    end
    
    dataout(i,[1:k,end-k+1:end]) = 0;    
end

end

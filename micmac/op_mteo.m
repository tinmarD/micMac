function [dataout] = op_mteo (datain, kvalues, smoothing, smoothingnorm)
% [dataout] = OP_MTEO (datain, kvalues, smoothing, smoothingnorm)
% Multiple k-Teager Energy Operator
%   INPUTS : 
%       datain          : (N*M) data matrix of N channels of M samples
%       k               : vector of k values
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

% For each channel
% h_wb = waitbar(0,'MTEO Operator');
for c=1:nchan
    tempout = zeros (length(kvalues),size(datain,2));
    % For each k value, compute the k-TEO signal
    for i=1:length(kvalues)
        tempout (i,:) = op_kteo (datain(c,:),kvalues(i),smoothing,smoothingnorm);
    end
    % Take the maximum value over the different k values
    dataout (c,:) = max(tempout,[],1);
%     try waitbar(c/nchan,h_wb); catch; end;
end
% try close(h_wb); catch; end;

end

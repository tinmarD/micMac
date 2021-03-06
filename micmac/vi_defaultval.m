function varargout = vi_defaultval(varargin)
% [varargout] = VI_DEFAULTVAL(varargin)
% Returns the default values of parameters specified as input. 
% ex: [obstimet_min, obstimet_max] = ...
%                   vi_defaultval ('obstimet_min','obstimet_max');
%
% See also vi_graphics


defaultvals = { 'obstimet_init',    0.6;...
                'obstimet_min',     0.005;...
                'obstimet_max',     600;...
                'obstimet_step',    0.1;...
                'ctimet_step',      0.2;...
                'buffer_size',      4;...
                'gain_min',         0.001;...
                'gain_max',         5;...
                'gain_step',        0.05;...      
                'unity_height',     400;...
                'wav_cycle_min',    4;...
                'wav_cycle_max',    10;...
                'visu_domains',     {'time','time-frequency','power spectrum','phase'};...
                'visu_domains_short',{'t','tf','f','ph'};...
                'wavelet_names',    {'cmor1-1.5','cmor1-1','cmor1-0.5','cmor1-2','cmor-var','morl','mexh','cgau5','shan2-3','morse'};...
                'wavelet_names_phase',{'cmor-var'};...
                'filter_type_freq', {'High Pass','Low Pass','Band Pass','Band Stop'};...
                'filter_type_name', {'FIR','Butterworth','Chebyshev Type I','Chebyshev Type II','Elliptic'};...
                'psd_methods',      {'Periodogram','Welch','Yule-Walker'};...
                'visumode_names',   {'stacked','spaced'};...
                'capture_dir',      'C:\Users\deudon\Documents\micMac';...
                'max_spaced_axis',  10;...
                'pyulear_order',    4;...
                'stim_duration_ratio',5;...
                'art_amp_thresh',   2000;...    % Maximum amplitude for artifact detection (in uV)
                'art_deriv_thresh', 750000;...  % Maximum slope for artifact detection (in uV/s)
                'colormap',         'viridis';...
                'tf_norm_method',   {'Log','Log-L�','Z-score','Z-H0','None'};... % First one is default one
                'colorscheme',      'dark';...  % 'light' or 'dark'
                'montages',         {'monopolar','bipolar','average','electrode-average'};...
                'electrode_types',  {'depth'};...                
                'line_freq',        50;...      % Line frequency (Hz)
                'captureQuality',   '-r500';... % Capture quality (Increase for more detail (dotPerInch))
};

varargout   = cell(1,nargin);

for i=1:length(varargin)
    input_i = varargin{i};
    if ~ischar(input_i)
        error ('input must be a string');
    end

    inputpos = nonzeros (strcmp(input_i,defaultvals(:,1)) .* ((1:size(defaultvals,1)).'));
    if isempty(inputpos)
        error (['Could not find the default value for the parameter named: ',...
                   input_i]);
    else
        varargout(i) = defaultvals(inputpos,2);
    end
end


end


function [z,p,k,sigdesc] = computefiltercoeff(srate, ftypefreqpos, ftypenamepos, forder, ...
    fclow, fchigh, fparam1val, fparam2val, sigdescin)
% [z,p,k,sigdesc] = COMPUTEFILTERCOEFF(srate, ftypefreqpos, ftypenamepos, ...
%   forder, fclow, fchigh, fparam1val, fparam2val, sigdescin)
%   Compute the filter coeffiecients given the parameters of the GUI
%   (pop_filtersignal)
%
% INPUTS :
%   - srate             : Sampling rate of the signal to filter (Hz)
%   - ftypefreqpos      : Position of the type of the filter (high-pass, low pass, ...)
%   - ftypenamepos      : Position of the name of the filter(implementation)
%   - forder            : Order of the filter
%   - fclow             : Low cut off frequency (Hz)
%   - fchigh            : High cut off frequency (Hz)
%   - fparam1val        : Additional parameter for band pass and band stop filters
%   - fparam2val        : Additional parameter for band pass and band stop filters
%   - sigdescin         : Description of the input signal
%
% OUTPUTS : 
%   - z, p, k           : for IIR filters, [z,p,k] structure (zeros and poles)
%                         for FIR filters, z=b and p=a=1
%   - sigdesc           : Description of the output signal
%
%
% See also pop_filtersignal


z = [];
p = [];
k = [];
sigdesc = [];

if nargin==8; sigdescin=''; end;

filtertypefreq  = vi_defaultval('filter_type_freq');
filtertypename  = vi_defaultval('filter_type_name');
ftypefreq       = filtertypefreq{ftypefreqpos};
ftypename       = filtertypename{ftypenamepos};

if isnan(forder); msgbox('Filter order must be numeric','Filter error'); return; end;
if forder<0; msgbox('Filter order must be positive','Filter error'); return; end;

%- Filter parameters verification
switch ftypefreq
    case 'High Pass'    
        if isnan(fchigh); msgbox('Cut-off frequency must be numeric','Filter error'); return; end;
        if fchigh<0 || fchigh>srate/2; msgbox('Cut-off frequency must be between 0 and FS/2','Filter error'); return; end;
        ffreq   = num2str(fchigh*2/srate);
        ftype   = 'high';
        sigdesc = [sigdescin,'_f>',num2str(fchigh),'Hz'];
    case 'Low Pass'
        if isnan(fclow); msgbox('Cut-off frequency must be numeric','Filter error'); return; end;
        if fclow<0 || fclow>srate/2; msgbox('Cut-off frequency must be between 0 and FS/2','Filter error'); return; end;
        ffreq   = num2str(fclow*2/srate);
        ftype   = 'low';
        sigdesc = [sigdescin,'_f<',num2str(fclow),'Hz'];
    case 'Band Pass'
        if isnan(fclow) || isnan(fchigh); msgbox('Cut-off frequences must be numeric','Filter error'); return; end;
        if fclow<0  || fclow>srate/2;  msgbox('Cut-off frequency must be between 0 and FS/2','Filter error'); return; end;
        if fchigh<0 || fchigh>srate/2; msgbox('Cut-off frequency must be between 0 and FS/2','Filter error'); return; end;
        if fclow>fchigh; msgbox('High cut-off frequency must be larger than low cut-off frequency','Filter error'); return; end;
        ffreq   = ['[',num2str(fclow*2/srate),',',num2str(fchigh*2/srate),']'];
        ftype   = 'bandpass';
        sigdesc = [sigdescin,'_',num2str(fclow),'Hz<f<',num2str(fchigh),'Hz'];
    case 'Band Stop'
        if isnan(fclow) || isnan(fchigh); msgbox('Cut-off frequences must be numeric','Filter error'); return; end;
        if fclow<0  || fclow>srate/2;  msgbox('Cut-off frequency must be between 0 and FS/2','Filter error'); return; end;
        if fchigh<0 || fchigh>srate/2; msgbox('Cut-off frequency must be between 0 and FS/2','Filter error'); return; end;
        if fclow>fchigh; msgbox('High cut-off frequency must be larger than low cut-off frequency','Filter error'); return; end;
        ffreq   = ['[',num2str(fclow*2/srate),',',num2str(fchigh*2/srate),']'];
        ftype   = 'stop';
        sigdesc = [sigdescin,'_','f<',num2str(fclow),'Hz-f>',num2str(fchigh),'Hz'];
end

foptions    = '';
switch ftypename
    case 'FIR';                 
        fname       = 'fir1';
    case 'Butterworth';         
        fname       = 'butter';
    case 'Chebyshev Type I';    
        fname       = 'cheby1';
        if isnan(fparam1val) || fparam1val<0; msgbox('Pass-band attenuation value must be numeric and positive','Filter error'); return; end;
        foptions    = [',',num2str(fparam1val)];
    case 'Chebyshev Type II';   
        fname       = 'cheby2';
        if isnan(fparam1val) || fparam1val<0; msgbox('Stop-band attenuation value must be numeric and positive','Filter error'); return; end;
        foptions    = [',',num2str(fparam1val)];
    case 'Elliptic';            
        fname       = 'ellip';
        if isnan(fparam1val) || fparam1val<0; msgbox('Pass-band attenuation value must be numeric and positive','Filter error'); return; end;
        if isnan(fparam2val) || fparam1val<0; msgbox('Stop-band attenuation value must be numeric and positive','Filter error'); return; end;
        foptions    = [',',num2str(fparam1val),',',num2str(fparam2val)];
end

filtstr = [fname,'(',num2str(forder),foptions,',',ffreq,',''',ftype,''');'];

if strcmp(ftypename,'FIR')
    p = 1;
    z = eval(filtstr);
else
    if verLessThan('matlab','8.1')
        warning(['Using filtfilt function with [b,a] coefficient structure because matlab version is too old',char(10),...
            'Current version is ',version,'. Would work better with version 8.1 (R2013a) or newer']);
        [z,p]   = eval(filtstr); % z = a & p = b ...
    else
        [z,p,k] = eval(filtstr);
    end
end
end

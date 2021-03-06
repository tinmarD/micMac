function VI = chancorrauto (VI, ALLSIG, Sig)
% VI = chancorrauto (VI, ALLSIG, Sig)
%   Try to compute automatically the channel correpondency between micMac
%   signal Sig and all the others signals
%   When called from addsignal function, Sig represents the newly created
%   signal and is in last position 

newsigpos   = length(ALLSIG);
% rawsigsum   = cumsum([ALLSIG.israw]);
% newsigpos   = rawsigsum(newsigpos);

for j=1:length(ALLSIG)-1
    Sig_j = ALLSIG(j);
    %- If signal is not raw signal, continue to the next one
    if ~Sig_j.israw
        continue;
    end
    
    %- First try to determine the micro Sig and the macro Sig based on the
    % first electrode name case
    sigmicronb = [];
    sigmacronb = [];
    sig1firstchanname = strtrim(Sig.channames{1});
    sig1firstelname   = regexp(sig1firstchanname,'[\w '']+','match');
    sig1firstelname   = strtrim(sig1firstelname{1});
    sig2firstchanname = strtrim(Sig_j.channames{1});
    sig2firstelname   = regexp(sig2firstchanname,'[\w '']+','match');
    sig2firstelname   = strtrim(sig2firstelname{1});
    %- Remove 'EEG' if present
    sig1firstelname   = strtrim(regexprep(sig1firstelname,'EEG',''));
    sig2firstelname   = strtrim(regexprep(sig2firstelname,'EEG',''));

    if ~isempty(regexp(sig1firstelname(1),'[a-z]','once'))
        sigmicronb = 1;
        SigMicro = Sig;
    else
        sigmacronb = 1;
        SigMacro = Sig;
    end
    if ~isempty(regexp(sig2firstelname(1),'[a-z]','once'))
        sigmicronb = 2;
        SigMicro = Sig_j;
    else
        sigmacronb = 2;
        SigMacro = Sig_j;
    end

    %- If the signal are not one micro and one Macro
    if isempty(sigmacronb) || isempty(sigmicronb)
        %- If the 2 signals have exactly the same channels
        channames_i = Sig.channames;
        channames_j = Sig_j.channames;
        if isequal(channames_i,channames_j)
            chancorr = repmat((1:Sig.nchan)',1,2);
            VI = addchancorr(VI,newsigpos,j,chancorr,chancorr);
            continue;
        elseif strcmpi('Status',channames_i(end)) || strcmpi('Status',channames_j(end))
            % Sometimes a Status channel appears and avoid correct
            % detection, retry without this channel (if present)
            channames_i(strcmpi('Status',channames_i)) = []; 
            channames_j(strcmpi('Status',channames_j)) = [];  
            if isequal(channames_i,channames_j)
                chancorr = repmat((1:Sig.nchan)',1,2);
                if length(channames_i) > length(channames_j)
                    chancorr_ij = chancorr;
                    chancorr_ji = [chancorr;0,0];
                else
                    chancorr_ij = [chancorr;0,0];
                    chancorr_ji = chancorr;
                end
                VI = addchancorr(VI,newsigpos,j,chancorr_ij,chancorr_ji);
                continue;
            end
        else
            continue;
        end

    else
        %- If micro and macro signals found
        micro2macrochancorr = zeros(SigMicro.nchan,2);
        macro2microchancorr = zeros(SigMacro.nchan,2);
        %- Get the list of the different micro-electrode names
        microelnames = regexp(SigMicro.channames,'[a-z]+''?','match');
        microelnames = strtrim(unique([microelnames{:}]));
        %- For each micro electrode name find the correspondig macro channels based
        % on the name
        for i=1:length(microelnames)
            macrochancorr = regexpi(SigMacro.channames,[microelnames{i},'\d+'],'match','once');
            macrochancorr = find(~cellfun(@isempty,macrochancorr));
            if isempty(macrochancorr)
                % If micro electrode name contains a p it migth be a '
                p_pos = regexp(microelnames{i},'p');
                if ~isempty(p_pos)
                    microelname_i_prime = microelnames{i};
                    microelname_i_prime(p_pos(end)) = '''';
                    macrochancorr = regexpi(SigMacro.channames,[microelname_i_prime,'\d+'],'match','once');
                    macrochancorr = find(~cellfun(@isempty,macrochancorr));
                    if isempty(macrochancorr)
                        continue;
                    end
                else
                    continue; 
                end;
            end
            macrochancorr = macrochancorr(1);
            microchancorr = regexp(SigMicro.channames,[microelnames{i},'\d+']);
            microchancorr = find(~cellfun(@isempty,microchancorr));
            if isempty(microchancorr); continue; end;
            micro2macrochancorr (microchancorr,:) = macrochancorr;
            macro2microchancorr (macrochancorr,:) = [min(microchancorr),max(microchancorr)];
        end

        % If the new signal is the micro-electrode one

        if sigmicronb==1
            VI = addchancorr(VI,newsigpos,j,micro2macrochancorr,macro2microchancorr);
        else
            VI = addchancorr(VI,newsigpos,j,macro2microchancorr,micro2macrochancorr);
        end
    end
    
end

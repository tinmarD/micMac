function [VI] = addchancorr(VI, sigposA, sigposB, chancorrAtoB, chancorrBtoA)
%[VI] = ADDCHANCORR (VI, sigpos1, sigpos2, chancorr1to2, chancorr2to1)
%   Add channel correspondencies to VI for signal given by sigpos1 and
%   sigpos2. Also add the correspondencies for other signal.
%   For example if signal 1 and 2 have correspondencies, adding a new
%   correpondencies between signal 1 and 3 will also add the
%   correspondencies between signal 3 and 2.

VI.chancorr{sigposA,sigposB} = chancorrAtoB;
VI.chancorr{sigposB,sigposA} = chancorrBtoA;

nSigs       = size(VI.chancorr,1);
otherSigPos = find(~ismember(1:nSigs,[sigposA,sigposB]));

nChanA      = size(chancorrAtoB,1);
nChanB      = size(chancorrBtoA,1);

for i=1:length(otherSigPos)
    sigpos_i        = otherSigPos(i);
    chancorrAtoi    = VI.chancorr{sigposA,sigpos_i};
    chancorritoA    = VI.chancorr{sigpos_i,sigposA};
    if ~isempty(chancorrAtoi)
        nChani          = size(VI.chancorr{sigpos_i,sigposA},1);
%         chancorrBtoi    = zeros(nChanB,2);
%         chancorritoB    = zeros(nChani,2);
        if ~isempty(VI.chancorr{sigposB,sigpos_i})
            chancorrBtoi    = zeros(nChanB,2);
            for iChan=1:nChanB
                if ~isequal(chancorrBtoA(iChan,:),[0,0])
                    cInStart            	= chancorrBtoA(iChan,1);
                    cInEnd               	= chancorrBtoA(iChan,2);
                    cOut                    = nonzeros(chancorrAtoi(cInStart:cInEnd,:));
                    if ~isempty(cOut)
                        chancorrBtoi(iChan,:)   = [min(cOut),max(cOut)];
                    end
                end
            end 
            VI.chancorr{sigposB,sigpos_i}   = chancorrBtoi;
        end
        if ~isempty(VI.chancorr{sigpos_i,sigposB})
            chancorritoB    = zeros(nChani,2);
            for iChan=1:nChani

                if ~isequal(chancorritoA(iChan,:),[0,0])
                    cInStart            	= chancorritoA(iChan,1);
                    cInEnd               	= chancorritoA(iChan,2);
                    cOut                    = nonzeros(chancorrAtoB(cInStart:cInEnd,:));
                    if ~isempty(cOut)
                        chancorritoB(iChan,:)   = [min(cOut),max(cOut)];
                    end
                end
            end
            VI.chancorr{sigpos_i,sigposB}   = chancorritoB;
        end
    else
        chancorrBtoi    = VI.chancorr{sigposB,sigpos_i};
        chancorritoB    = VI.chancorr{sigpos_i,sigposB};
        if ~isempty(chancorrBtoi)
            nChani          = size(VI.chancorr{sigpos_i,sigposB},1);
%             chancorrAtoi    = zeros(nChanA,2);
%             chancorritoA    = zeros(nChani,2);
            if ~isempty(VI.chancorr{sigposA,sigpos_i})
                chancorrAtoi    = zeros(nChanA,2);
                for iChan=1:nChanA
                    if ~isequal(chancorrAtoB(iChan,:),[0,0])
                        cInStart            	= chancorrAtoB(iChan,1);
                        cInEnd               	= chancorrAtoB(iChan,2);
                        cOut                    = nonzeros(chancorrBtoi(cInStart:cInEnd,:));
                        if ~isempty(cOut)
                            chancorrAtoi(iChan,:)   = [min(cOut),max(cOut)];
                        end
                    end
                end 
                VI.chancorr{sigposA,sigpos_i}   = chancorrAtoi;
            end
            if ~isempty(VI.chancorr{sigpos_i,sigposA})
                chancorritoA    = zeros(nChani,2);
                for iChan=1:nChani
                    if ~isequal(chancorritoB(iChan,:),[0,0])
                        cInStart            	= chancorritoB(iChan,1);
                        cInEnd               	= chancorritoB(iChan,2);
                        cOut                    = nonzeros(chancorrBtoA(cInStart:cInEnd,:));
                        if ~isempty(cOut)
                            chancorritoA(iChan,:)   = [min(cOut),max(cOut)];
                        end
                    end
                end
                VI.chancorr{sigpos_i,sigposA}   = chancorritoA;
            end
        end
    end
end



end


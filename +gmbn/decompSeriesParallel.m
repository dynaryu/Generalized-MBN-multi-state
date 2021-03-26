function branches = decompSeriesParallel(subCapas)

import gmbn.*

numSub = length(subCapas);
branches = []; % flag = system capacity
for nn = 1:numSub    
    capas_n = subCapas{nn};
    for cc = 1:length(capas_n)
        [capa_nc,lowBound_nc,upBound_nc] = initDecompSP( numSub,nn,capas_n,cc );
        [lowBound_nc,upBound_nc,idx_nc] = checkAheadSub( subCapas(1:(nn-1)),capa_nc,lowBound_nc,upBound_nc );
        if idx_nc
            [lowBound_nc,upBound_nc,idx_nc] = checkBehindSub( subCapas((nn+1):end),nn,capa_nc,lowBound_nc,upBound_nc,idx_nc );
        end
        if idx_nc
            branch_nc = branch( lowBound_nc,upBound_nc,[],capa_nc );
            branches = [branches; branch_nc];
        end
    end        
end
end

function [capa,lowBound,upBound] = initDecompSP( numSub,subIdx,capas,capaIdx )
    capa = capas(capaIdx);
    lowBound = zeros(1,numSub); upBound = zeros(1,numSub);
    lowBound(subIdx) = capaIdx; upBound(subIdx) = capaIdx;
end

function [lowBound,upBound,idx] = checkAheadSub( aheadSubCapas,capa,lowBound,upBound )
    idx = 1;
    for nn = 1:length(aheadSubCapas)
        idx_n = find( aheadSubCapas{nn} > capa );
        if isempty( idx_n )
            idx = 0;
            break;
        else
            lowBound(nn) = idx_n(1);
            upBound(nn) = idx_n(end);
        end
    end
end

function [lowBound,upBound,idx] = checkBehindSub( behindSubCapas,subIdx,capa,lowBound,upBound,idx )
    for nn = 1:length( behindSubCapas )
        idx_n = find( behindSubCapas{nn} >= capa );
        if isempty( idx_n )
            idx = 0;
            break;
        else
            lowBound(subIdx+nn) = idx_n(1);
            upBound(subIdx+nn) = idx_n(end);
        end
    end
end
function [Mmult,vInfo] = multCPMs(M,vInfo)

import gmbn.*

Mmult = nullCPM;
for mm = 1:length(M)
    [Mmult,vInfo] = product(Mmult,M(mm),vInfo);
end
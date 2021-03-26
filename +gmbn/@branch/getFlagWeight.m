function flagWeight = getFlagWeight( branches,flags )

import gmbn.*

flagWeight = zeros(size(flags));
for ff = 1:length(flags)
    [~,branchIdx] = findFlag(branches,flags(ff));
    flagWeight(ff) = sumWeight( branches,branchIdx );
end
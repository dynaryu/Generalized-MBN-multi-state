function [branchMax,branchMaxIdx,maxWeight] = maxWeight(branches,branchFlag)

import gmbn.*

weights = arrayfun(@(x) x.weight, branches);

if nargin > 1
    [~,branchFlagIdx] = findFlag(branches,branchFlag);
    [maxWeight,branchMaxIdx] = max(weights(branchFlagIdx));
    branchMaxIdx = branchFlagIdx(branchMaxIdx);    
else
    [maxWeight,branchMaxIdx] = max(weights);    
end

branchMax = branches(branchMaxIdx);



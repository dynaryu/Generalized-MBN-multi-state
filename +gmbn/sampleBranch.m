function [branch_sampled,branchIdx_sampled,sampleProb] = sampleBranch(unspecBranches,unspecWeightNorm)

import gmbn.*

branchIdx_sampled = randsample(length(unspecWeightNorm),1,true,unspecWeightNorm); 
sampleProb = unspecWeightNorm(branchIdx_sampled);
branch_sampled = unspecBranches(branchIdx_sampled);
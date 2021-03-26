function [unspecBranches,unspecWeightNorm] = initSamplingUnspecBranch(branches)

import gmbn.*

unspecBranches = findFlag(branches,0);
unspecWeight = arrayfun(@(x) x.weight, unspecBranches);
unspecWeightNorm = myNormalize(unspecWeight);
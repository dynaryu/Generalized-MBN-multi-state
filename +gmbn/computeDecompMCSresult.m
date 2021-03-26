function [mean,cov] = computeDecompMCSresult( probByDecomp,probSampled,numSamp,numDetect )

import gmbn.*

[meanMCS,covMCS] = computeMCSresult(numSamp,numDetect);
mean = probByDecomp + meanMCS*probSampled;
stdMCS = meanMCS*covMCS;
std = stdMCS*probSampled;
cov = std/mean;
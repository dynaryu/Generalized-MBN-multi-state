function [sampleIdx,sampleVal,sampleProb] = sampleInBranch(branch,varsVal,varsProbs)

import gmbn.*

numVars = length(varsProbs);

sampleIdx = zeros(1,numVars);
sampleVal = zeros(1,numVars);
sampleProb = log(1);

for vv = 1:numVars
    states_v = branch.lowBound(vv):branch.upBound(vv);
    prob_v = varsProbs{vv}( states_v );
    prob_v = myNormalize(prob_v);
    if length(states_v) < 2
        samp_v = 1;
    else
        samp_v = randsample(length(prob_v),1,true,prob_v);
    end
    sampVal_v = states_v(samp_v);

    sampleIdx(vv) = sampVal_v;
    sampleVal(vv) = varsVal{vv}(sampVal_v);
    sampleProb = sampleProb + log(prob_v(samp_v));
end
sampleProb = exp(sampleProb);

function prob = updateProb( prob,changedVarsProbs,oldLowIdx,oldUpIdx,newLowIdx,newUpIdx )

prob = log(prob);
for ii = 1:length(changedVarsProbs)
    probOld_i = sum( changedVarsProbs{ii}(oldLowIdx(ii):oldUpIdx(ii)) );
    probNew_i = sum( changedVarsProbs{ii}(newLowIdx(ii):newUpIdx(ii)) );
    prob = prob - log(probOld_i) + log(probNew_i);
end
prob = exp(prob);
function prob = getProb( lowIdx,upIdx,probs )

prob = log(1);
for ii = 1:length(probs)
    prob_i = sum( probs{ii}(lowIdx(ii):upIdx(ii)) );
    prob = prob + log(prob_i);
end
prob = exp(prob);
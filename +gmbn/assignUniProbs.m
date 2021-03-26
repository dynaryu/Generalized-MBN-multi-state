function uniProbs = assignUniProbs( events )

uniProbs = cell(size(events));
for ii = 1:length(events)
    uniProbs_i = ones(size(events{ii}));
    uniProbs_i = exp( log(uniProbs_i)-log(sum(uniProbs_i)) ); 
    uniProbs{ii} = uniProbs_i;
end
function weight = sumWeight( branches,idx )

import gmbn.*

if nargin < 2
    idx = 1:length(branches);
end
weight = arrayfun( @(x) x.weight, branches(idx));
weight = sum(weight);
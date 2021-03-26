function [cliques,vInfo] = runCliqueTrees( cliqueIdx,messSched,CPM,vInfo )

import gmbn.*

% Initialize
for cc = 1:length(cliqueIdx)
    cliques{cc} = multCPMs( CPM( cliqueIdx{cc} ), vInfo );
end

% Message-passing
for mm = 1:size(messSched,1)
    sched_m = messSched(mm,:);
    
    clique1 = cliques{sched_m(1)}; clique2 = cliques{sched_m(2)}; 
    sumVars_m = setdiff( clique1.variables,clique2.variables );
    [clique2_m,vInfo] = product( clique1,clique2,vInfo );
    clique2_m = sum( clique2_m,sumVars_m );
    cliques{sched_m(2)} = clique2_m;
end
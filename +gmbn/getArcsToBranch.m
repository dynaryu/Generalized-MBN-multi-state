function arcsToBranch = getArcsToBranch( branch1,arcs,arcsCapas,targetFlowAdj )

import gmbn.*
numArcs = length( arcsCapas );

arcsCapaLow = getArcsCapa( branch1.lowBound,arcsCapas );
arcsToBranch = [];
for aa = 1:numArcs
    arcs_a = arcs(aa,:);
    flow_a = targetFlowAdj(arcs_a(1),arcs_a(2));
    if flow_a > arcsCapaLow(aa)
        branchIdx_ = find( arcsCapas{aa}>=flow_a , 1 );
        arcsToBranch = [arcsToBranch; aa branchIdx_];
    end
end

arcsToBranchCapa = getArcsCapa( arcsToBranch(:,2),arcsCapas(arcsToBranch(:,1)) );
arcsToBranchGap = arcsToBranchCapa - arcsCapaLow(arcsToBranch(:,1));
[~,arcsToBranchOrder] = sort(arcsToBranchGap);
arcsToBranch = arcsToBranch(arcsToBranchOrder,:);
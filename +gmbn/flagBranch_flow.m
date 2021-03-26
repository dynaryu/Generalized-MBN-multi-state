function branches = flagBranch_flow( branches,arcs,arcsCapas,sNode,tNode,targetFlow )

import gmbn.*

for bb = 1:length(branches)-1
    arcsCapa_b = getArcsCapa( branches(bb).upBound,arcsCapas );
    G_b = graph( arcs(:,1),arcs(:,2),arcsCapa_b );
    mf_b = maxflow( G_b,sNode,tNode );
    if mf_b < targetFlow
        branches(bb).flag = 2;
    else
        arcsCapa_b = getArcsCapa( branches(bb).lowBound,arcsCapas );
        G_b = graph( arcs(:,1),arcs(:,2),arcsCapa_b );
        mf_b = maxflow( G_b,sNode,tNode );
        if mf_b >= targetFlow
            branches(bb).flag = 1;
        end
    end
end
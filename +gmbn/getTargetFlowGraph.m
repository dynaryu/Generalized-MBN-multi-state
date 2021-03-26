function targetFlowAdj = getTargetFlowGraph( arcs,arcsCapa,sNode,tNode,targetFlow )

numNode = max(arcs(:));

[arcsAug,arcsCapaAug] = augmentGraphForTargetFlow(arcs,arcsCapa,tNode,targetFlow);

G = graph( arcsAug(:,1),arcsAug(:,2),arcsCapaAug );
[~,GF] = maxflow( G,sNode,numNode+1 );

targetFlowAdj = adjacency(GF,'weighted');
targetFlowAdj(:,end) = [];
targetFlowAdj(end,:) = [];
targetFlowAdj = targetFlowAdj + targetFlowAdj';

end

function [arcsAug,arcsCapaAug] = augmentGraphForTargetFlow(arcs,arcsCapa,tNode,targetFlow)

import gmbn.*

numNode = max(arcs(:)); numArc = size(arcs,1);

arcsAug = [arcs; tNode numNode+1];
arcsCapaAug = [arcsCapa; targetFlow];

[arcsAug,arcsCapaAug] = sortArcs(arcsAug,arcsCapaAug);

end
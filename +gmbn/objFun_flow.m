function objVal = objFun_flow( arcs,arcsCapa,sNode,tNode,targetFlow )
%{
Evaluate objective value of network flow problem:
objVal: 1 -- Survive; 2 -- Failure
%}

G = graph(arcs(:,1),arcs(:,2),arcsCapa);
mf = maxflow(G,sNode,tNode);
if mf < targetFlow
    objVal = 2;
else
    objVal = 1;
end
function [branches,flagWeight] = branchFun_flow( branch1,arcs,arcsCapas,arcsProbs,sNode,tNode,targetFlow,flags )
%{
Branch and bound for network flow problem
flag: 0 - unspecified; 1 - specified as system survival; 2 - specifeid as system failure
%}

import gmbn.*

arcsCapa = getArcsCapa( branch1.upBound,arcsCapas );
targetFlowAdj = getTargetFlowGraph( arcs,arcsCapa,sNode,tNode,targetFlow );
arcsToBranch = getArcsToBranch( branch1,arcs,arcsCapas,targetFlowAdj );
branches = doBranch( branch1,arcsToBranch,arcsProbs );
branches = flagBranch_flow( branches,arcs,arcsCapas,sNode,tNode,targetFlow );
flagWeight = getFlagWeight( branches,flags );

function [branches,flagWeight] = BnB_flow( arcs,arcsCapas,arcsProbs,sNode,tNode,targetFlow,flags,targetUnspecGap )

import gmbn.*

numArcs = size(arcs,1);
branches = branch(ones(numArcs,1),cellfun(@length,arcsCapas),1,0);
unspecGap = 1; flagWeight = [1 0 0];
decompFlag = 0; decompFlagIdx = find( flags==decompFlag );

numIter = 0;
while unspecGap > targetUnspecGap
    numIter = numIter+1;
    
    [branchToDecompose_,branchToDecomposeIdx_,branchDecomposeWeight_] = maxWeight(branches,decompFlag);
    [branches_,flagWeight_] = branchFun_flow( branchToDecompose_,arcs,arcsCapas,arcsProbs,sNode,tNode,targetFlow,flags );
    [flagWeight,unspecGap] = updateFlagWeight(flagWeight,[branchDecomposeWeight_ 0 0],flagWeight_,decompFlagIdx);
    branches = updateBranches( branches,branchToDecomposeIdx_,branches_ );
    
    disp(['Iteration ' num2str(numIter) '| Unspecfied weight: ' num2str(unspecGap)] )
end
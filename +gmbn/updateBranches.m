function branches = updateBranches( branches,oldBranchIdx,newBranches )

branches(oldBranchIdx) = [];
branches = [branches; newBranches];
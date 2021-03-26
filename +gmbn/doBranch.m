function br = doBranch( branch1,varToBranch,varProbs )

import gmbn.*

setWeight = branch1.weight;

lowBound_ = branch1.lowBound; upBound_ = branch1.upBound;

for aa = 1:size(varToBranch,1)
    arc_a = varToBranch(aa,1);
    upBound_(arc_a) = varToBranch(aa,2)-1;
    
    setWeight = updateProb( setWeight,varProbs(arc_a),branch1.lowBound(arc_a),branch1.upBound(arc_a),lowBound_(arc_a),upBound_(arc_a));
    
    br(aa,1) = branch(lowBound_,upBound_,setWeight,0); % flag 0: unspecified
    
    upBound_(arc_a) = branch1.upBound(arc_a);
    lowBound_(arc_a) = varToBranch(aa,2);
    
    setWeight = updateProb( setWeight,varProbs(arc_a),branch1.lowBound(arc_a),varToBranch(aa,2)-1,lowBound_(arc_a),upBound_(arc_a));
end

br(aa+1,1) = branch(lowBound_,upBound_,setWeight,1); % flag 1: specified as system survival

function [CPMnew,vInfo] = sumProductVE( CPM,varElimOrder,vInfo )

import gmbn.*

for vv = 1:length(varElimOrder)
    elimVar_v = varElimOrder(vv);
    [CPM,vInfo] = SumProductEliminateVar( CPM,elimVar_v,vInfo );
end
[CPMnew,vInfo] = multCPMs(CPM,vInfo);

end

function [CPMnew,vInfo] = SumProductEliminateVar( CPM,var,vInfo )

import gmbn.*

flag = isXinScope( var,CPM );
CPMnew = CPM(~flag);
CPM = CPM(flag);
[cpm,vInfo] = multCPMs( CPM,vInfo );
cpm = sum( cpm,var );
CPMnew = [cpm; CPMnew];

end
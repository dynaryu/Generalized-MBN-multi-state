function [CPMnew,vInfo] = runCondVE( CPM,condVars,varElimOrder,vInfo )
%{
Inference by conditioning on condVars and Sum-Product variable elimination on other variables
%}
import gmbn.*

varElimOrder = setdiff(varElimOrder,condVars,'stable');
varElimOrder = varElimOrder(:)'; condVars = condVars(:)';

Ccond = (1:size(vInfo(condVars(1)).B,2) )';
for vv = 2:length(condVars)
    numState_v = size( vInfo(condVars(vv)).B,2 );
    Ccond = [repmat(Ccond,numState_v,1) repelem((1:numState_v)',size(Ccond,1),1 )];
end

for cc = 1:size(Ccond,1)
    condState_c = Ccond(cc,:);

    [CPMcond_c,vInfo] = condition(CPM,condVars,condState_c,vInfo);
    [CPMquery_c,vInfo] = sumProductVE( CPMcond_c,[varElimOrder condVars],vInfo );
    
    if cc < 2
        CPMnew = CPMquery_c;
    else
        CPMnew = CPMnew + CPMquery_c;
    end   
    
end
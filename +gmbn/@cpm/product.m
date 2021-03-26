function [Mproduct,vInfo] = product(M1,M2,vInfo)

import gmbn.*

if ~isempty( intersect( M1.variables(1:M1.numChild),M2.variables(1:M2.numChild) ) )
    error('PMFs must not have common child nodes')
end

if size(M1.C,2) > size(M2.C,2)
    M1_ = M1;
    M1 = M2;
    M2 = M1_;
end

if ~isempty(M1.C)
    commonVars=intersect(M1.variables,M2.variables);

    flagCommonVarsInM1 = ismember(M1.variables,M2.variables);
    commonVars = M1.variables(flagCommonVarsInM1);
    C1 = M1.C; p1 = M1.p;
    Cproduct = []; pproduct = [];
    for rr = 1:size(C1,1)
        c1_r = C1(rr,flagCommonVarsInM1);
        c1_notCommon_r = C1(rr,~flagCommonVarsInM1);

        [M2_r,vInfo] = condition(M2,commonVars,c1_r,vInfo);
        Cproduct = [Cproduct; M2_r.C repmat(c1_notCommon_r,size(M2_r.C,1),1)];
        pproduct = [pproduct; exp( log(M2_r.p)+log(p1(rr)) )];
    end

    Cproduct_vars = [M2.variables M1.variables(~flagCommonVarsInM1)];

    newVarsChild = [M1.variables(1:M1.numChild) M2.variables(1:M2.numChild)];
    newVarsChild = sort(newVarsChild);
    newVarsParent = [M1.variables(M1.numChild+1:end) M2.variables(M2.numChild+1:end)];
    newVarsParent = setdiff(newVarsParent,newVarsChild);
    newVars = [newVarsChild newVarsParent];

    [~,idxVars] = ismember(newVars,Cproduct_vars);
    Cproduct = Cproduct(:,idxVars);

    Mproduct = cpm;
    Mproduct.variables = newVars;
    Mproduct.numChild = length(newVarsChild);
    Mproduct.C = Cproduct; Mproduct.p = pproduct;
    Mproduct = sort(Mproduct);
else
    Mproduct = M2;
end


function [Mcond,vInfo] = condition(M,condVars,condStates,vInfo)

import gmbn.*

Mcond = M;

for mm = 1:length(M)

    compatFlag_m = isCompatible(M(mm).C,M(mm).variables,condVars,condStates,vInfo);

    Ccompat_m = M(mm).C(compatFlag_m,:);
    Ccond_m = zeros(size(Ccompat_m));

    [~,idxInC_m] = ismember(condVars,M(mm).variables);
    [~,idxIncondVars_m] = ismember(M(mm).variables,condVars);

    Ccond_m(:,~idxIncondVars_m) = Ccompat_m(:,~idxIncondVars_m);

    condVars_m = condVars(idxInC_m>0);
    condStates_m = condStates(idxInC_m>0);

    idxInC_m(~idxInC_m) = [];

    for vv = 1:length(condVars_m)
        condVar_mv = condVars_m(vv);
        condState_mv = condStates_m(vv);
        idxInC_mv = idxInC_m(vv);

        B_mv = vInfo(condVar_mv).B;
        Ccompat_mv = Ccompat_m(:,idxInC_mv);

        compatCheck_mv = B_mv(Ccompat_mv,:) .* B_mv( condState_mv,: );
        B_mv = addNewStatesToB(compatCheck_mv,B_mv);
        vInfo(condVar_mv).B = B_mv;

        [~,Cintersected_mv] = ismember(compatCheck_mv,B_mv,'rows');
        Ccond_m(:,idxInC_mv) = Cintersected_mv;
    end

    Mcond(mm).C = Ccond_m;
    Mcond(mm).p = M(mm).p(compatFlag_m);
    
end

end

function B = addNewStatesToB(states,B)
    newStateCheck = ~ismember(states,B,'rows');
    newState = states(newStateCheck,:);
    newState = unique(newState,'rows');    
    if ~isempty(newState)
        B = [B; newState];
    end
end
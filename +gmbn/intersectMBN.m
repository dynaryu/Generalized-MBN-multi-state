function [Mintersected,vInfo] = intersectMBN(M,interVars,interStates,vInfo)

import gmbn.*

Mintersected = M;

for mm = 1:length(M)

    compatFlag_m = isCompatible(M(mm).C,M(mm).variables,interVars,interStates,vInfo);

    Ccompat_m = M(mm).C(compatFlag_m,:);
    Cintersected_m = zeros(size(Ccompat_m));

    [~,idxInC_m] = ismember(interVars,M(mm).variables);
    [~,idxInInterVars_m] = ismember(M(mm).variables,interVars);

    Cintersected_m(:,~idxInInterVars_m) = Ccompat_m(:,~idxInInterVars_m);

    interVars_m = interVars(idxInC_m>0);
    interStates_m = interStates(idxInC_m>0);

    idxInC_m(~idxInC_m) = [];

    for vv = 1:length(interVars_m)
        interVar_mv = interVars_m(vv);
        interState_mv = interStates_m(vv);
        idxInC_mv = idxInC_m(vv);

        B_mv = vInfo(interVar_mv).B;
        Ccompat_mv = Ccompat_m(:,idxInC_mv);

        compatCheck_mv = B_mv(Ccompat_mv,:) .* B_mv( interState_mv,: );
        B_mv = addNewStatesToB(compatCheck_mv,B_mv);
        vInfo(interVar_mv) = B_mv;

        [~,Cintersected_mv] = ismember(compatCheck_mv,B_mv,'rows');
        Cintersected_m(:,idxInC_mv) = Cintersected_mv;
    end

    Mintersected(mm).C = Cintersected_m;
    Mintersected(mm).p = M(mm).p(compatFlag_m);
    
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
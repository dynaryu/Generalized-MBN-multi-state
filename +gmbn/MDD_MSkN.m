function [M,vInfo,var] = MDD_MSkN( k,N,numCompState,M,vInfo,var,compIdx )

import gmbn.*

var_ = length(vInfo)+1;

% Xbar_0
var.Xbar(1) = var_; 
M(var_) = cpm(var_,1,3,1);
vInfo(var_) = varsInfo(eye(3),[zeros(1,numCompState);-ones(1,numCompState);k]); % v: vector of remaining demands (states 1/2 are reserved for system survival/failure)

for nn=1:N
    var_ = var_+1;
    var.Xbar(nn+1) = var_;
    vInfo(var_) = varsInfo( eye(2),[zeros(1,numCompState);-ones(1,numCompState)] );
    C_n = []; Xbar_old_state_n = unique(M(var_-1).C(:,1));
    
    for cc = 1:length(Xbar_old_state_n)
        state_c = Xbar_old_state_n(cc);
        if state_c == 1 || state_c == 2 % system event specified in pre-round
            [compState_nc,vInfo(compIdx(nn))] = getAndUpdateCompStateFromVinfo(ones(1,1+numCompState),vInfo(compIdx(nn)));
            C_n = [C_n;state_c compState_nc state_c];
        else
            stateVal_c = vInfo(var_-1).v(state_c,:);
            if all(stateVal_c < 2)
                s_nc = find( stateVal_c > 0 , 1, 'last' );
                b_nc = zeros(1,numCompState+1); b_nc((s_nc+1):end) = 1;
                [compState_nc,vInfo(compIdx(nn))] = getAndUpdateCompStateFromVinfo(b_nc,vInfo(compIdx(nn)));
                C_n = [C_n;1 compState_nc state_c];
            else
                s_nc = numCompState+1;
            end
            if sum( stateVal_c == N-(nn-1) )
                t_nc = find(stateVal_c == N-(nn-1), 1, 'last' );
                b_nc = zeros(1,numCompState+1); b_nc(1:t_nc) = 1;
                [compState_nc,vInfo(compIdx(nn))] = getAndUpdateCompStateFromVinfo(b_nc,vInfo(compIdx(nn)));
                C_n = [C_n;2 compState_nc state_c];
            else
                t_nc = 0;
            end
            for xx = t_nc:(s_nc-1)
                stateVal_cx = stateVal_c - [ones(1,xx) zeros(1,numCompState-xx)];
                [state_ncx,vInfo(var_)] = getAndUpdateCompStateFromVinfo(stateVal_cx,vInfo(var_),'v');
                C_n = [C_n; state_ncx xx+1 state_c];
            end
        end
        M(var_) = cpm([var_ compIdx(nn) var_-1],1,C_n,ones(size(C_n,1),1));
    end
end
var.S = var.Xbar(end); var.Xbar(end) = [];
vInfo(var.S).v = {'survival' 'failure'}';

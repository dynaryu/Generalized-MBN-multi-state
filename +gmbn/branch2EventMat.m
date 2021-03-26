function [Csys,sysVinfo,compVinfo] = branch2EventMat( branches,compVinfo )

import gmbn.*

if isnumeric(branches(1).flag)
    isFlagNum=1;
    vSys = [];
else
    isFlagNum=0;
    vSys = {};
end

Ncomp = length(compVinfo);
Csys = [];
for bb = 1:length(branches)
    br_ = branches(bb);
    c_b = zeros(1,Ncomp+1);
    for nn = 1:Ncomp
        B_bn = zeros(1,size(compVinfo(nn).B,2));
        B_bn( br_.lowBound(nn):br_.upBound(nn) ) = 1;
        state_bn = ismember(compVinfo(nn).B,B_bn,'rows');
        if all(~state_bn)
            compVinfo(nn).B = [compVinfo(nn).B; B_bn];
            c_b(nn+1) = size( compVinfo(nn).B,1 );
        else
            c_b(nn+1) = find(state_bn);
        end
    end
    
    if isFlagNum
        state_b = ismember( vSys,br_.flag );        
    else
        state_b = strcmp( vSys,br_.flag );
    end
    if sum( state_b )
        c_b(1) = find(state_b);
    else
        vSys = [vSys; br_.flag];
        c_b(1) = length(vSys);
    end
        
    Csys = [Csys; c_b];
end

% Sort state in ascending order of v
if isFlagNum
    [vSys,vind] = sort(vSys);
    [~,vind2] = sort(vind);
    Csys(:,1) = vind2( Csys(:,1) );
end

% varsInfo of system
sysVinfo =varsInfo;
sysVinfo.B = eye(length(vSys));
sysVinfo.v = vSys;
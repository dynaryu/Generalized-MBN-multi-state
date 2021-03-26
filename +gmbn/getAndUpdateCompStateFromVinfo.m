function [state,vInfo1] = getAndUpdateCompStateFromVinfo(info,vInfo1,flagBorV)
% Get state that accords with a row of B
% If there is no such row b in B, create one

% flagBorV: 'B' (default) or 'v' - given info?

if nargin < 3
    flagBorV = 'B';
end

if strcmp(flagBorV,'B')        
    [state,vInfo1] = getAndUpdateCompStateFromB(info,vInfo1);       
    
elseif strcmp(flagBorV,'v')        
    [state,vInfo1] = getAndUpdateCompStateFromV(info,vInfo1);    
    
else
    error('flagBorV must be either not given (or empty), B, or v')
end

end

function [state,vInfo1] = getAndUpdateCompStateFromB(b1,vInfo1)
    idx_ = ismember(vInfo1.B,b1,'rows');
    if sum(idx_)
        state = find(idx_);
    else
        vInfo1.B = [vInfo1.B; b1];
        state = size(vInfo1.B,1);
    end    
end
    
function [state,vInfo1] = getAndUpdateCompStateFromV(v1,vInfo1)
    if isscalar(v1)
        state = find( vInfo1.v == v1 );
    else
        state = find( ismember( vInfo1.v,v1,'rows' ) );
    end
    if isempty( state )
        stateNum = size(vInfo1.B,2);
        state = stateNum+1;
        vInfo1.B = [vInfo1.B zeros(size(vInfo1.B,1),1); zeros(1,stateNum) 1];
        vInfo1.v = [vInfo1.v; v1];
    end    
end
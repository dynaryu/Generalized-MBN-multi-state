function Msum = sum(M,sumVars,sumFlag)
% sumFlag: 1 (default) - sum out sumVars; 0 - leave only sumVars


if length(M) > 1
    error('M must be a single CPM')
end
if nargin < 3
    sumFlag = 1;
end

if sumFlag && ~isempty( intersect( M.variables(M.numChild+1:end),sumVars ) )
    warning('Parent nodes are NOT summed up')
end
% if ~sumFlag && ~isempty( setdiff(M.variables(M.numChild+1:end),sumVars) )
%     warning('Parent nodes are NOT summed up')
% end

import gmbn.*

if sumFlag
    [varsRemain,varsRemainIdx] = setdiff(M.variables(1:M.numChild),sumVars,'stable');
    varsRemainIdx = varsRemainIdx(:)';
else
    [~,varsRemainIdx] = ismember( sumVars,M.variables(1:M.numChild) );
    varsRemainIdx = varsRemainIdx(varsRemainIdx>0);
    varsRemainIdx = sort(varsRemainIdx(:)');
    varsRemain = M.variables( varsRemainIdx );
end
Msum = cpm;
Msum.numChild = length( varsRemain );

if ~isempty( M.variables(M.numChild+1:end) )
    varsRemain = [varsRemain M.variables(M.numChild+1:end)];
    varsRemainIdx = [varsRemainIdx (M.numChild+1):length(M.variables)];
end

C = M.C(:,varsRemainIdx); p = M.p;

if isempty(C)
    Csum = zeros(1,0); psum = sum(p);    
else
    Csum = []; psum = [];
    while ~isempty(C)

        c_ = C(1,:); 
        sameRulesIdx = ismember(C,c_,'rows');
        Csum = [Csum; c_];
        psum = [psum; sum(p(sameRulesIdx))];

        C(sameRulesIdx,:) = [];
        p(sameRulesIdx) = [];

    end
end

Msum.variables = varsRemain;
Msum.C = Csum;
Msum.p = psum;
Msum = sort(Msum);
    
    


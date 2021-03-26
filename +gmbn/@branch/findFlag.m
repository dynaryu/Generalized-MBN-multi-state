function [branches,branchIdx] = findFlag(branches,flag,flagIdx,scalarIdx)
%{
flagIdx: 1 (default) find desginated flag; 0 - find that are not the designated flag
scalarIdx: 1 (default) flag regarded as scalar; 0 - given flag regarded as row vector
%}
import gmbn.*

if nargin < 3
    flagIdx = 1;
    scalarIdx = 1;
elseif nargin < 4
    scalarIdx = 1;
    if isempty(flagIdx)
        flagIdx = 1;
    end
end

branchIdx = false(length(branches),1);
if scalarIdx
    flags = arrayfun(@(x) x.flag,branches );
    for ff = 1:length(flag)
        branchIdx = branchIdx | ( flags == flag(ff) );
    end
else
    flags = arrayfun(@(x) x.flag,branches,'UniformOutput',0 );
    for ff = 1:size(flag,1)
        branchIdx = branchIdx | cellfun( @(x) isequal( x,flag(ff,:) ),flags );
    end
end

if ~flagIdx
    branchIdx = ~branchIdx;
end
branchIdx = find(branchIdx);
branches = branches(branchIdx);
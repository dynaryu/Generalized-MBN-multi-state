function [arcs,varargout] = sortArcs(arcs,varargin)

arcs = sort(arcs,2);
[arcs,arcsSortIdx] = sortrows(arcs);

varargout = cell(size(varargin));
for vv = 1:length(varargin)
    varargout{vv} = varargin{vv}(arcsSortIdx,:);
end

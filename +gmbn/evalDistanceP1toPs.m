function Distances = evalDistanceP1toPs(point1,points)
%{
Evaluate distances b/w one point to multiple points
%}

Distances = zeros( size(points,1),1 ); 
for ii = 1:size(points,1)
    Distances(ii) = norm( point1-points(ii,:) );
end
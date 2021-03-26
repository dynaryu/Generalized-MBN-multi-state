function arcsCapa = getArcsCapa( capaIdx,arcsCapas )

numArcs = length(capaIdx);
arcsCapa = zeros(numArcs,1);
for aa = 1:numArcs
    arcsCapa(aa) = arcsCapas{aa}(capaIdx(aa));
end

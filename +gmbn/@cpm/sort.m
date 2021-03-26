function Msorted = sort(M)

import gmbn.*
Msorted = M;

[~,CsortIdx] = sortrows(M.C(:,end:-1:1));
Msorted.C = M.C(CsortIdx,: );
Msorted.p = M.p(CsortIdx);
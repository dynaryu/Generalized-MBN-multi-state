function CPMnew = plus( CPM1,CPM2 )
%{
Output:
Variable order of CPM1 is preserved
%}

import gmbn.*

if ~isequal( CPM1.variables(1:CPM1.numChild),CPM2.variables(1:CPM2.numChild) ) || ...
        ~isequal( CPM1.variables((CPM1.numChild+1):end),CPM2.variables((CPM2.numChild+1):end) )
    error('Given CPMs must be defined over the same distribution')
end

Cnew = CPM1.C; pnew = CPM1.p;
[~,vars2_idx] = ismember( CPM2.variables,CPM1.variables );
[~,vars2_idx] = sort(vars2_idx);
C2 = CPM2.C(:,vars2_idx); p2 = CPM2.p;
for cc = 1:length(p2)
   idx = find( ismember(Cnew,C2(cc,:),'rows') );
   if isempty(idx)
       Cnew = [Cnew; C2(cc,:)]; pnew = [pnew; p2(cc)];
   else
       idx = idx(1);
       pnew(idx) = pnew(idx)+p2(cc);
   end
end

CPMnew = CPM1;
CPMnew.C = Cnew; CPMnew.p = pnew;
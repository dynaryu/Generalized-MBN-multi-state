clear;
import gmbn.*

%% Input parameters
Mcomp = 3; % maximum number of states
N = 20; % number of components
k1=[10 7 4]; k2=[5 11 5]; k3=[4 7 10]; % target demand

probDeriorate = .2; % probability of segment being deteriorated
probFailDeriorate = .3; % probability of segment failing given deterioration
probFailNondeterior = .1; % probability of segment failing given non-deterioration

%% Quantification
var_ = 0; M = cpm;
% Dnk: deterioration of segment k of pipeline n
for nn = 1:N
    for kk = 1:Mcomp
        var_ = var_+1;
        var.D(nn,kk) = var_;
        vInfo(var_,1) = varsInfo( eye(2),{'true' 'false'} );
        if kk > 1
            vInfo(var_).B = [vInfo(var_).B; 1 1]; % composite state Dnk=3
        end
        M(var_,1) = cpm( var_,1,[1 2]',[probDeriorate 1-probDeriorate]' );
    end
end

% Xn: pipeline n; P(Xn|Dn3,Dn2,Dn1)
% (1) Xn=1: satisfied states ~ 0
Cx = [ones(2,1) 3*ones(2,Mcomp-1) [1 2]']; px = [probFailDeriorate probFailNondeterior]';
% (2) Xn=2:Mcomp: statisfied states ~ 1:(Mcomp-1)
for kk = 2:Mcomp
    Cx_k = (1:2)'; px_k = log([1-probFailDeriorate 1-probFailNondeterior]');
    for kk2 = 2:(kk-1)
        Cx_k = [repmat((1:2)',size(Cx_k,1),1) repelem(Cx_k,2,1)];
        px_k = repelem(px_k,2,1) + repmat(log([1-probFailDeriorate 1-probFailNondeterior]'),length(px_k),1);
    end
    Cx_k = [repmat((1:2)',size(Cx_k,1),1) repelem(Cx_k,2,1)];
    px_k = repelem(px_k,2,1) + repmat(log([probFailDeriorate probFailNondeterior]'),length(px_k),1);
    
    Cx_k = [kk*ones(size(Cx_k,1),1) 3*ones(size(Cx_k,1),Mcomp-kk) Cx_k];
    px_k = exp(px_k);
    
    Cx = [Cx; Cx_k]; px = [px; px_k];
end
% (3) Xn=Mcomp+1: statisfied states ~ Mcomp
Cx_k(:,1) = Mcomp+1;
px_k = exp( log(px_k) - log( repmat([probFailDeriorate probFailNondeterior]',length(px_k)/2,1 ) ) + ...
    log( repmat([1-probFailDeriorate 1-probFailNondeterior]',length(px_k)/2,1 ) ) );
Cx = [Cx; Cx_k]; px = [px; px_k];

for nn = 1:N
    var_ = var_+1;
    var.X(nn) = var_;
    vInfo(var_) = varsInfo( eye(Mcomp+1),(0:Mcomp)' ); % v: maximum state that can be served
    M(var_) = cpm( [var_ var.D(nn,end:-1:1)],1,Cx,px );
end
        
% System event quantification
[M1,vInfo1,var] = MDD_MSkN( k1,N,Mcomp,M,vInfo,var,var.X );
[M2,vInfo2] = MDD_MSkN( k2,N,Mcomp,M,vInfo,var,var.X );
[M3,vInfo3] = MDD_MSkN( k3,N,Mcomp,M,vInfo,var,var.X );

%% Inference by Clique Trees
% Build clique trees and Message scheduling
nn2 = 0; messSched = [];
for nn = 1:N
    nn2 = nn2+1;
    cliqueIdx{nn2,1} = [var.D(nn,:) var.X(nn)];
    nn2 = nn2+1;
    if nn == 1
        cliqueIdx{nn2,1} = [var.Xbar(1) var.Xbar(2)];
    else
        cliqueIdx{nn2,1} = var.Xbar(nn)+1;
    end
    messSched = [messSched; nn2-1 nn2];
    if nn > 1
        messSched = [messSched; nn2-2 nn2];
    end
end

% Run Clique Trees
[cliques1,vInfo1] = runCliqueTrees( cliqueIdx,messSched,M1,vInfo1 );
[cliques2,vInfo2] = runCliqueTrees( cliqueIdx,messSched,M2,vInfo2 );
[cliques3,vInfo3] = runCliqueTrees( cliqueIdx,messSched,M3,vInfo3 );

Msys(1) = sum(cliques1{end},var.S,0);
Msys(2) = sum(cliques2{end},var.S,0);
Msys(3) = sum(cliques3{end},var.S,0);

disp('System failure probability')
disp( arrayfun( @(x) x.p(2),Msys ) )

% Number of rules
numRules(:,1) = arrayfun( @(x) size(x.C,1), M1([var.Xbar var.S]) );
numRules(:,2) = arrayfun( @(x) size(x.C,1), M2([var.Xbar var.S]) );
numRules(:,3) = arrayfun( @(x) size(x.C,1), M3([var.Xbar var.S]) );
numRules = sum(numRules);
disp('Number of rules used for quantyfing system event')
disp( numRules )

save demoMDD_kN
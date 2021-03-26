clear;
import gmbn.*

%% Initalization and Decomposition
% Parameters
Ncomp = [5 7 10 3];
CapaComp = [10 8 6 12];
RelComp = [.8 .6 .5 .9];
ProbFault = [1e-3 3e-3 2e-3 1e-3];

% Capacity values of subsystems
Nsub = length(Ncomp);
for nn = 1:Nsub
   subCapas{nn,1} = CapaComp(nn)*(0:Ncomp(nn)); 
end

% Decomposition for system event
branches = decompSeriesParallel(subCapas);

%% MBN Quantification
M = cpm; vInfo = varsInfo; 

% Cn
var_ = 0;
for nn = 1:Nsub
    var_ = var_+1;
    var.C(nn) = var_;
    
    M(var_).variables = var_;
    M(var_).numChild = 1;
    M(var_).C = (0:Ncomp(nn))'+1;
    M(var_).p = binopdf( (0:Ncomp(nn))',Ncomp(nn),RelComp(nn) );
    vInfo(var_).B = [eye( Ncomp(nn)+1 ); ones(1,Ncomp(nn)+1)];
    vInfo(var_).v = (0:Ncomp(nn))'; % number of survivng components
end

% Fn
for nn = 1:Nsub
    var_ = var_+1;
    var.F(nn) = var_;
    
    M(var_).variables = var_;
    M(var_).numChild = 1;
    M(var_).C = [1 2]';
    M(var_).p = [ProbFault(nn) 1-ProbFault(nn)]';
    vInfo(var_).B = eye( 2 );
    vInfo(var_).v = {'true' 'false'}';
end

% Xn
for nn = 1:Nsub
    var_ = var_+1;
    var.X(nn) = var_;
    
    M(var_).variables = [var_ var.F(nn) var.C(nn)];
    M(var_).numChild = 1;
    M(var_).C = [[1 1 Ncomp(nn)+2]; [(0:Ncomp(nn))'+1 2*ones(Ncomp(nn)+1,1) M(var.C(nn)).C]]; % [Fn=true; Fn=false]
    M(var_).p = ones( size(M(var_).C,1),1 );
    vInfo(var_).B = eye( Ncomp(nn)+1 );
    vInfo(var_).v = CapaComp(nn) * (0:Ncomp(nn)); % capacity
end

% S
var_ = var_+1;
var.S = var_;

M(var_).variables = [var_ var.X];
M(var_).numChild = 1;

% from Branch to Event matrix
[Csys,sysVinfo,vInfo(var.X)] = branch2EventMat( branches,vInfo(var.X) );

M(var_).C = Csys;
M(var_).p = ones(size(Csys,1),1);
vInfo(var_) = sysVinfo;

%% Inference by Clique Trees
for ss = 1:Nsub
    cliqueIdx{ss} = [var.C(ss) var.F(ss) var.X(ss)];
end
cliqueIdx{Nsub+1} = var.S;

messSched = [(1:Nsub)' (Nsub+1)*ones(Nsub,1)];

% Run Clique Trees
[cliques,vInfo] = runCliqueTrees( cliqueIdx,messSched,M,vInfo );

% Get P(S)
Msys = sum(cliques{Nsub+1},var.S,0);

%% Sensitivity analysis
delR = [.05 .07 .1 .03]; % improvement of R given unit cost

% Change probability vector
Msens_C = M(var.C);
for vv = 1:Nsub
    Nc_v = Ncomp(vv); R_v = RelComp(vv);
    p_v = zeros(Nc_v+1,1);
    for mm = 0:Nc_v
        p_v(mm+1) = log( nchoosek(Nc_v,mm) ) +  (mm-1)*log(R_v) + (Nc_v-mm-1)*log(1-R_v) + log( mm*(1-R_v)+(Nc_v-mm)*R_v );
    end
    p_v = exp(p_v);
    Msens_C(vv).p = p_v;
end

% Run Clique Trees
Msens_sys = cpm; % derivative of P(S) on R_1,...,R_N
for nn = 1:Nsub
    Msens_n = M;
    Msens_n(var.C(nn)) = Msens_C(nn);
    [cliques_sens_n,vInfo] = runCliqueTrees( cliqueIdx,messSched,Msens_n,vInfo );
    Msens_sys(nn) = sum(cliques_sens_n{Nsub+1},var.S,0);
end

% Result of sensitivity analysis
deriv_R = zeros(1,Nsub);
for nn = 1:Nsub
    deriv_R(nn) = sum( Msens_sys(nn).p( vInfo(var.S).v<10 ) );
end

%% Result
Fsz = 18; Fsz_tick = 16;

% 1. CDF of P(S)
plot( vInfo(var.S).v,cumsum(Msys.p),'sq--','linewidth',1.5 );
grid on
axis([0 40 0 1])
set(gca, 'FontSize', Fsz_tick,'FontName','times new roman')
xlabel( '\it{X_{N+1}}','Fontsize',Fsz,'FontName','times new roman' )
ylabel( 'CDF of \it{X_{N+1}}','Fontsize',Fsz,'FontName','times new roman' )

saveas(gcf,'figure/MSSP_CDF.emf')
saveas(gcf,'figure/MSSP_CDF.pdf')

disp(['P(S<10): ' num2str(sum(Msys.p(vInfo(var.S).v<10)))])

% 2. Sensitivity analysis
disp('Upgrade worth:')
disp( deriv_R.*delR )
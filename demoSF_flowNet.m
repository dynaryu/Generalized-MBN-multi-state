clear;
import gmbn.*

%% Input
load data/SFarcs.txt
load data/SFnodes.txt
arcs = sortrows(SFarcs);
nodes = SFnodes(:,2:3)*1e-5; % km

probD1 = .05; % probability of Road n being deteriorated
probI0D1 = .2; probI1D0 = .05; % Probability of inspection error
PGACapa = [.85 1; 1.0 1.2]; % [d1; d2]

targetUnspecGap = .001; % Probability of unspecified sets

N = size(arcs,1);

%% Quantification
var_ = 0;
% M: EQ magnitude
var_ = var_+1;
var.M = var_;
MstateVal = .5*( (6:0.5:8)' + (6.5:.5:8.5)' ); % mid-point of each interval
Mp = 1 / ( 1-exp( -.76*(8.5-6) ) ) * ( 1-exp( -.76*( (6:.5:8.5)'-6 ) ) );
Mp = diff( Mp );
M(var_) = cpm(var_,1,(1:5)',Mp);
vInfo(var_) = varsInfo( eye(5),MstateVal );

% L: Epicenter location
var_ = var_+1;
var.L = var_;
LstateVal = [(-2:2)' (-2:-1:-6)']; % (x,y) location of epicenter (km)
Lp = ones( size(LstateVal,1),1 ); Lp = Lp / sum(Lp);
M(var_,1) = cpm(var_,1,(1:length(Lp))',Lp);
vInfo(var_,1) = varsInfo( eye(length(Lp)),LstateVal );

% Dn: Deterioration of Road n
for nn = 1:N
    var_ = var_+1;
    var.D(nn) = var_;
    M(var_) = cpm( var_,1,(1:2)',[probD1 1-probD1] );
    vInfo(var_) = varsInfo( eye(2),{'deteriorated' 'intact'}' );
end

% In: Inspection result
for nn = 1:N
    var_ = var_+1;
    var.I(nn) = var_;
    M(var_) = cpm( [var_ var.D(nn)],1,[repmat((1:2)',2,1) repelem((1:2)',2,1)],[1-probI0D1 probI0D1 probI1D0 1-probI1D0] );
    vInfo(var_) = varsInfo( eye(2),{'deteriorated' 'intact'}' );
end

% Xn: Component event capacity of Road n P(Xn|Dn,L,M)
% % Event matrix
Cx = M(var.M).C; % M
Cx = [repmat(M(var.L).C,size(Cx,1),1) repelem(Cx,size(M(var.L).C,1),1)]; % L
Cx = [repmat((1:2)',size(Cx,1),1) repelem(Cx,2,1)]; % Dn
Cx = [repmat((1:3)',size(Cx,1),1) repelem(Cx,3,1)]; % Xn

for nn = 1:N
    var_ = var_+1;
    var.X(nn) = var_;
    
    % Prob Vector
    L_n = mean( nodes( arcs(nn,:),: ) ); % Road n's centroid
    R_n = evalDistanceP1toPs(L_n,vInfo(var.L).v);
 
    logPGACapa = log([.85 1; 1.0 1.2]); % [d1; d2]
    % Magnitude
    px_n = [];
    for mm = 1:length( vInfo(var.M).v )
        M_m = vInfo(var.M).v(mm);
        for rr = 1:length( R_n)
            logAh_mr = -3.512+.904*M_m-1.328*log( sqrt(R_n(rr)^2+(.149*exp(.647*M_m))^2) ); % Campbell (1997)
            std_mr = getStd_Campbell97( logAh_mr );
            
            prob_mr = normcdf( logPGACapa,logAh_mr,std_mr );
            prob_mr = diff([[0 0]' prob_mr [1 1]'],1,2);
            prob_mr = prob_mr(:,end:-1:1)';
            px_n = [px_n; prob_mr(:)];
        end
    end

    M(var_) = cpm( [var_ var.D(nn) var.L var.M],1,Cx,px_n );
    vInfo(var_) = varsInfo( eye(3),[0 2 3]' ); % capacity value       
    
end

% S: system event P(S|X1...XN)
% % Branch and Bound
arcCapas = arrayfun( @(x) x.v, vInfo(var.X), 'UniformOutput',0 );

[M_m5,vInfo] = condition( M,var.M,5,vInfo );
arcProbs = {};
for nn = 1:N
    [M_Xm5_n,vInfo] = multCPMs( M_m5([var.X(nn) var.D(nn) var.L var.M]),vInfo );
    M_Xm5_n = sum(M_Xm5_n,var.X(nn),0);
    pX_n = myNormalize( M_Xm5_n.p ); 
    arcProbs = [arcProbs; {pX_n'}];
end

flags = [0 1 2]; % branch's flag: [unspecified survival failure]
sNode=13; tNode=2; targetFlow=4;
[branches,flagWeight] = BnB_flow( arcs,arcCapas,arcProbs,sNode,tNode,targetFlow,flags,targetUnspecGap );

BranchesSurvive = findFlag(branches,1);
BranchesFail = findFlag(branches,2);

[Csys,sysVinfo,vInfo(var.X)] = branch2EventMat( [BranchesSurvive;BranchesFail],vInfo(var.X) );
var_ = var_+1;
var.S = var_;
M(var_) = cpm([var.S var.X],1,Csys,ones(size(Csys,1),1));
vInfo(var_) = sysVinfo; vInfo(var_).v = {'survival' 'failure'}';

%% Inference by conditioning (1) with no observation
condVars = [var.M var.L];
varElimOrder = [var.I var.D var.X];

% System Reliability
[CPMsys,vInfo] = runCondVE( M,condVars,varElimOrder,vInfo );
disp('System failure probability (lower and upper bounds): ')
disp( [CPMsys.p(2) 1-CPMsys.p(1)] )

% Component importance measure
CIM = zeros( N,2 ); % [lower upper] bounds of P(Xn<3|System failure)
for nn = 1:N
    varElimOrder_n = setdiff( varElimOrder,var.X(nn),'stable' );
	[CPMsysComp_n,vInfo] = runCondVE( M,condVars,varElimOrder_n,vInfo );
    
    idxSysFail_n = isCompatible( CPMsysComp_n.C,CPMsysComp_n.variables,var.S,2,vInfo );
    idxSysCompFail_n = isCompatible( CPMsysComp_n.C,CPMsysComp_n.variables,[var.S var.X(nn)],[2 1],vInfo ) | ...
        isCompatible( CPMsysComp_n.C,CPMsysComp_n.variables,[var.S var.X(nn)],[2 2],vInfo );
    
    pSysFail_n = [sum(CPMsysComp_n.p(idxSysFail_n)) 1-sum(CPMsysComp_n.p(~idxSysFail_n))]; % [lower upper] bounds of P(System failure)
    pSysCompFail_n = [sum(CPMsysComp_n.p(idxSysCompFail_n)) 1-sum(CPMsysComp_n.p(~idxSysCompFail_n))]; % [lower upper] bounds of P(Xn<3 and System failure)
    
    CIM(nn,:) = [pSysCompFail_n(1)/pSysFail_n(2) pSysCompFail_n(2)/pSysFail_n(1)];
    CPMsysComp(nn,1) = CPMsysComp_n;
end

%% Inference by conditioning (2) with observation on I
% Inspection scenario
rng(1)
inspection = randsample( 2,N,true,[.5 .5] );
[Minsp,vInfo] = condition( M,var.I,inspection,vInfo ); 

probInsp = log(1);
for nn = 1:N
   [M_In,vInfo] = product( M(var.I(nn)),M(var.D(nn)),vInfo );
   M_In = sum(M_In,var.I(nn),0);
   probInsp = probInsp + log( M_In.p(inspection(nn)) );
end
probInsp = exp(probInsp);

condVars_insp = setdiff(condVars,var.I,'stable');
% System Reliability
[CPMsys_insp,vInfo] = runCondVE( Minsp,condVars_insp,varElimOrder,vInfo );
CPMsys_insp.p = exp( log(CPMsys_insp.p) - log(probInsp) );
disp('System failure probability updated by inspection (lower and upper bounds): ')
disp( [CPMsys_insp.p(2) 1-CPMsys_insp.p(1)] )

% Component importance measure
CIMinsp = zeros( N,2 ); % [lower upper] bounds of P(Xn<3|System failure)
for nn = 1:N
    varElimOrder_n = setdiff( varElimOrder,var.X(nn),'stable' );
	[CPMsysComp_n,vInfo] = runCondVE( Minsp,condVars,varElimOrder_n,vInfo );
    
    idxSysFail_n = isCompatible( CPMsysComp_n.C,CPMsysComp_n.variables,var.S,2,vInfo );
    idxSysCompFail_n = isCompatible( CPMsysComp_n.C,CPMsysComp_n.variables,[var.S var.X(nn)],[2 1],vInfo ) | ...
        isCompatible( CPMsysComp_n.C,CPMsysComp_n.variables,[var.S var.X(nn)],[2 2],vInfo );
    
    CPMsysComp_n.p = exp( log(CPMsysComp_n.p)-log(probInsp) );
    
    pSysFail_n = [sum(CPMsysComp_n.p(idxSysFail_n)) 1-sum(CPMsysComp_n.p(~idxSysFail_n))]; % [lower upper] bounds of P(System failure)
    pSysCompFail_n = [sum(CPMsysComp_n.p(idxSysCompFail_n)) 1-sum(CPMsysComp_n.p(~idxSysCompFail_n))]; % [lower upper] bounds of P(Xn<3 and System failure)
    
    CIMinsp(nn,:) = [pSysCompFail_n(1)/pSysFail_n(2) pSysCompFail_n(2)/pSysFail_n(1)];
    CPMsysComp_insp(nn,1) = CPMsysComp_n;
end

save demoSF_flowNet

%% Figure: Graph
G = graph(arcs(:,1),arcs(:,2));
G_I1 = graph(arcs(inspection==1,1),arcs(inspection==1,2));
G_I2 = graph(arcs(inspection==2,1),arcs(inspection==2,2));

figure;
h{1} = plot(G,'xData',nodes(:,1),'yData',nodes(:,2),'NodeLabel',[],'EdgeLabel',1:N,'EdgeColor',[1 1 1]);
h{1}.EdgeFontSize = 12;
hold on
h{2} = plot(G_I1,'xData',nodes(:,1),'yData',nodes(:,2),'NodeLabel',[],'LineWidth',2,'EdgeColor',[1 0 0],'EdgeAlpha',1,'NodeColor',[.5 .5 .5],'LineStyle','--');
h{3} = plot(G_I2,'xData',nodes(:,1),'yData',nodes(:,2),'NodeLabel',[],'LineWidth',2,'EdgeColor',[0 0 1],'EdgeAlpha',1,'NodeColor',[.5 .5 .5]);

textLoc = [nodes(sNode,:); nodes(tNode,:)] + [-.22 0; .1 0];
text( textLoc(:,1),textLoc(:,2),{'\it{s}' '\it{t}'},'FontSize',24,'FontWeight','bold','FontName','times new roman' )

legend([h{3} h{2}],'I_n=0','I_n=1','Fontsize',14,'FontName','times new roman','Location','NorthEast')
set(gca, 'FontSize', 14,'FontName','times new roman')
xlabel( 'x-direction (km)','Fontsize',16,'FontName','times new roman' )
ylabel( 'y-direction (km)','Fontsize',16,'FontName','times new roman' )

saveas(gcf,'figure/SFnetwork.emf')
saveas(gcf,'figure/SFnetwork.pdf')
hold off
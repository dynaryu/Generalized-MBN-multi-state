clear;

rng(1)
import gmbn.*
load demoSF_flowNet M var vInfo N arcs sNode tNode targetFlow

cov_t = .03; % target c.o.v.

cov = 1; numSamp = 0; numFail = 0; Samp = [];
while cov > cov_t
    numSamp = numSamp+1;
    
    m_ = randsample( M(var.M).C,1,true,M(var.M).p );
    l_ = randsample( M(var.L).C,1,true,M(var.L).p );
    [M_,vInfo] = condition( M,[var.M var.L],[m_ l_],vInfo );
    
    x_ = zeros(1,N); arcCapa_ = zeros(N,1);
    for nn = 1:N
        M_n = multCPMs( M( M(var.X(nn)).variables ),vInfo ); 
        M_n = sum( M_n,var.X(nn),0 );
        x_(nn) = randsample( M_n.C,1,true,M_n.p ); 
        arcCapa_(nn) = vInfo(var.X(nn)).v( x_(nn) );
    end
    
    G = graph(arcs(:,1),arcs(:,2),arcCapa_);
    f_ = maxflow( G,sNode,tNode );
    
    if f_ < targetFlow % system failure
        numFail = numFail+1;
        samp_ = [0 x_ m_ l_]; % [S X L M]
    else
        samp_ = [1 x_ m_ l_];
    end
    Samp = [Samp; samp_];
    
    mu = numFail / numSamp; std = sqrt( (1-mu)*mu/numSamp );
    
    if numSamp > 10 && numFail > 0
        cov = std/mu;
    end
    
    if ~rem(numSamp,500)
       disp( [num2str(numSamp) ' samples: (mu, c.o.v.) = ( ' num2str(mu) ', ' num2str(cov) ' )'] ) 
    end
    
end

disp(['P(system failure) and c.o.v.: ' num2str(mu) ' and ' num2str(cov)])

% Component importance measure
CIM_mcs = zeros(N,1); CIM_std_mcs = zeros(N,1);
idxSysFail = ~Samp(:,1);
for nn = 1:N
    numCompSysFail_n = sum( Samp(idxSysFail,1+nn)<3 );
    
    mu_n = numCompSysFail_n / numFail;
    std_n = sqrt( (1-mu_n)*mu_n/numFail );
    
    CIM_mcs(nn) = mu_n;  CIM_std_mcs(nn) = std_n;
end
    
save demoSF_flowNet_MCS

%% Figure: CIM
load demoSF_flowNet CIM CIMinsp
[~,idxHighCIM] = sort( CIM(:,1),'descend' );
figure;
hold on
for ii = 1:5
    idx_i = idxHighCIM(ii);
    h{1} = plot( [ii;ii],CIM_mcs( idx_i )+2.58*CIM_std_mcs(idx_i)*[1 -1],'Color',[.7 .7 .7],'LineWidth',10);
end
for ii = 1:5
    idx_i = idxHighCIM(ii);
    h{2} = plot( [ii;ii],CIM(idx_i,:),'r*--','LineWidth',1);
end
for ii = 1:5
    idx_i = idxHighCIM(ii);
    h{3} = plot( [ii;ii],CIMinsp(idx_i,:),'bo--','LineWidth',1);
end
legend( [h{1} h{2} h{3}],'MCS 99% CI','MBN & BnB','MBN & BnB w/ inspection','Fontsize',16,'FontName','times new roman' )

axis([.5 5.5 0 0.5])
xticks(1:5)
xticklabels( idxHighCIM(1:5) )
set(gca, 'FontSize', 14,'FontName','times new roman')
xlabel( 'n','Fontsize',18,'FontName','times new roman' )
ylabel( 'CPIM','Fontsize',18,'FontName','times new roman' )
grid on
saveas(gcf,'figure/SF_CPIM.emf')
saveas(gcf,'figure/SF_CPIM.pdf')
hold off

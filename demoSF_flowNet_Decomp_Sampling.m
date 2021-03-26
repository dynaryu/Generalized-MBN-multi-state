clear;
import gmbn.*

flags = [0 1 2]; % branch's flag: [unspecified survival failure]
targetUnspecGap = .05;

load data/SFarcs.txt
load data/SFnodes.txt
arcs = SFarcs;
numArcs = size(arcs,1);

arc1Capa = [0 2 3]; arc1Prob = [.01 .04 .95];
for aa = 1:numArcs
    arcsCapas{aa,1} = arc1Capa; % All arcs have same capacity
    arcsProbs{aa,1} = arc1Prob;
end

[arcs,arcsCapas,arcsProbs] = sortArcs(arcs,arcsCapas,arcsProbs);
G = graph(arcs(:,1),arcs(:,2));
plot(G,'xData',SFnodes(:,2),'yData',SFnodes(:,3),'EdgeLabel',1:numArcs);

sNode=13; tNode=2; targetFlow=4;
[branches,flagWeight] = BnB_flow( arcs,arcsCapas,arcsProbs,sNode,tNode,targetFlow,flags,targetUnspecGap );

%% Sampling
targetCov = .01*(1/flagWeight(1)+1); % Assuming that meanMCS will be similar to probByDecomp, i.e. flagWeight(3)

[unspecBranches,unspecWeightNorm] = initSamplingUnspecBranch(branches);
numUnspec = length(unspecBranches);

samples = []; numSamp = 0; cov = 1; numDetect = 0;
while cov > targetCov
    numSamp = numSamp+1;
    
    [br_,brIdx_,prBr_] = sampleBranch(unspecBranches,unspecWeightNorm);
    [samp_,sampCapa_,prSample_] = sampleInBranch(br_,arcsCapas,arcsProbs);
    state_ = objFun_flow( arcs,sampCapa_,sNode,tNode,targetFlow );
    
    if state_==2 % system failure
        numDetect = numDetect+1;
    end
        
    sample_ = sampling(samp_,state_,exp(log(prBr_)+log(prSample_)));
    samples = [samples; sample_];
    
    [mean,cov] = computeMCSresult(numSamp,numDetect);
    
    if ~rem(numSamp,1e2)
        disp(['Samp ' num2str(numSamp) ' | Mean ' num2str(mean) ' | cov ' num2str(cov)])
    end
end

[mean,cov] = computeDecompMCSresult( flagWeight(3),flagWeight(1),numSamp,numDetect );
disp(['Samling result (mean, cov) = (' num2str(mean) ', ' num2str(cov) ')'])
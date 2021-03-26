clear;
import gmbn.*
import brml.*

%% Distributions
[hazard,road1,road2,road3,add1,add2,capa1,capa2,capa3,capa4,demand1,demand2,sys1,sys2] = assign(1:14);

M = cpm; vInfo = varsInfo;
M(hazard).variables = hazard;
M(hazard).numChild = 1;
M(hazard).C = [1 2 3]'; M(hazard).p = [.7 .2 .1];
vInfo(hazard).B = eye(3); vInfo(hazard).v = {'insig' 'moderate' 'intense'};

M(road1).variables = [road1 hazard];
M(road1).numChild = 1;
M(road1).C = [repmat((1:3)',3,1) repelem((1:3)',3,1)];
M(road1).p = [.99 .009 .001 .9 .09 .01 .7 .2 .1];
vInfo(road1).B = [eye(3); 1 1 0; 0 1 1; 1 1 1]; vInfo(road1).v = {'intact' 'severe' 'destruct'};

M(road2).variables = [road2 hazard];
M(road2).numChild = 1;
M(road2).C = [repmat((1:3)',3,1) repelem((1:3)',3,1)];
M(road2).p = [.95 .04 .01 .8 .15 .05 .6 .25 .15];
vInfo(road2).B = [eye(3); 1 1 0; 0 1 1; 1 1 1]; vInfo(road2).v = {'intact' 'severe' 'destruct'};

M(road3).variables = [road3 hazard];
M(road3).numChild = 1;
M(road3).C = [repmat((1:3)',3,1) repelem((1:3)',3,1)];
M(road3).p = [.96 .03 .01 .85 .12 .03 .65 .22 .13];
vInfo(road3).B = [eye(3); 1 1 0; 0 1 1; 1 1 1]; vInfo(road3).v = {'intact' 'severe' 'destruct'};

M(add1).variables = [add1 hazard];
M(add1).numChild = 1;
M(add1).C = [repmat((1:2)',3,1) repelem((1:3)',2,1)];
M(add1).p = [.001 .999 .01 .99 .1 .9];
vInfo(add1).B = eye(2); vInfo(add1).v = {'intact' 'collapse'};

M(add2).variables = [add2 hazard];
M(add2).numChild = 1;
M(add2).C = [repmat((1:2)',3,1) repelem((1:3)',2,1)];
M(add2).p = [.01 .99 .1 .9 .3 .7];
vInfo(add2).B = eye(2); vInfo(add2).v = {'intact' 'collapse'};

M(capa1).variables = [capa1 road1 road2 add1];
M(capa1).numChild = 1;
M(capa1).C = [1 6 6 1;1 6 4 2;3 1 3 2;2 2 3 2;1 3 3 2]; M(capa1).p = ones(5,1);
vInfo(capa1).B = [eye(3);1 1 0;0 1 1;1 1 1]; vInfo(capa1).v = {'capa 0' 'capa 1' 'capa 2'};

M(capa2).variables = [capa2 road2 add2];
M(capa2).numChild = 1;
M(capa2).C = [1 6 1;2 1 2;1 5 2]; M(capa2).p = ones(3,1);
vInfo(capa2).B = [eye(2);1 1]; vInfo(capa2).v = {'capa 0' 'capa 1'};

M(capa3).variables = [capa3 road2 add2];
M(capa3).numChild = 1;
M(capa3).C = [1 6 1;3 4 2;2 3 2]; M(capa3).p = ones(3,1);
vInfo(capa3).B = [eye(3);1 1 0;0 1 1;1 1 1]; vInfo(capa3).v = {'capa 0' 'capa 1' 'capa 2'};

M(capa4).variables = [capa4 road3];
M(capa4).numChild = 1;
M(capa4).C = [3 1;2 2;1 3]; M(capa4).p = ones(3,1);
vInfo(capa4).B = [eye(3);1 1 0;0 1 1;1 1 1]; vInfo(capa4).v = {'capa 0' 'capa 1' 'capa 2'};

M(demand1).variables = [demand1 hazard];
M(demand1).numChild = 1;
M(demand1).C = [repmat((1:2)',3,1) repelem((1:3)',2,1)]; M(demand1).p = [.9 .1 .5 .5 .1 .9];
vInfo(demand1).B = eye(2); vInfo(demand1).v = {'demand 1' 'demand 2'};

M(demand2).variables = [demand2 hazard];
M(demand2).numChild = 1;
M(demand2).C = [repmat((1:2)',3,1) repelem((1:3)',2,1)]; M(demand2).p = [.8 .2 .2 .8 .5 .5];
vInfo(demand2).B = eye(2); vInfo(demand2).v = {'demand 1' 'demand 2'};

M(sys1).variables = [sys1 capa1 capa2 demand1];
M(sys1).numChild = 1;
M(sys1).C = [2 1 1 1; 1 1 2 1; 1 5 3 1; 2 1 3 2; 2 2 1 2; 1 2 2 2; 1 3 3 2];
M(sys1).p = ones(7,1);
vInfo(sys1).B = eye(2); vInfo(sys1).v = {'survive' 'fail'};

M(sys2).variables = [sys2 capa3 capa4 demand2];
M(sys2).numChild = 1;
M(sys2).C = [2 1 6 1; 2 5 1 1; 1 5 5 1; 2 4 6 2; 2 3 4 2; 1 3 3 2];
M(sys2).p = ones(6,1);
vInfo(sys2).B = eye(2); vInfo(sys2).v = {'survive' 'fail'};

M = errCheck(M);

%% Inference
condFlag = 0; sys1Prob = zeros(2,1); sys2Prob = zeros(2,1);

for hh = 1:3
    Mcond_h = condition(M,hazard,hh,vInfo);
    clique1 = multCPMs(Mcond_h([road1:road3 add1:add2 capa1:capa4]),vInfo);
    clique2 = multCPMs(Mcond_h([demand1 sys1]),vInfo);
    clique3 = multCPMs(Mcond_h([demand2 sys2]),vInfo);

    mess12 = sum(clique1,[capa1 capa2],0);
    mess13 = sum(clique1,[capa3 capa4],0);

    clique2_update = multCPMs([clique2 mess12],vInfo); clique2_update = sum(clique2_update,sys1,0);
    clique3_update = multCPMs([clique3 mess13],vInfo);
    clique3_update = sum(clique3_update,sys2,0);
    
    sys1Prob = sys1Prob + exp( log(clique2_update.p) + log(M(hazard).p(hh)) );
    sys2Prob = sys2Prob + exp( log(clique3_update.p) + log(M(hazard).p(hh)) );
end

disp(['Failure probability : (sys1, sys2) = (' num2str(sys1Prob(2)) ', ' num2str(sys2Prob(2)) ')'])
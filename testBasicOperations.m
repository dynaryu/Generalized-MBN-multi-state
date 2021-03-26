import gmbn.*

M = cpm;
M(1).variables = [1 2 3];
M(1).numChild = 1;
M(1).C = [1 3 5;2 3 5;3 3 5;1 1 2;2 1 2;1 2 2;2 2 2;3 2 2;1 1 3;3 1 3;1 2 3;3 2 3];
M(1).p = [.7 .2 .1 .6 .4 .5 .2 .3 .2 .8 .1 .9];

M(2).variables = 2;
M(2).numChild = 1;
M(2).C = [1 2]';
M(2).p = [.3 .7];

M(3).variables = 3;
M(3).numChild = 1;
M(3).C = [1 2 3 4]';
M(3).p = [.1 .2 .3 .4];

M = errCheck(M);

vInfo = varsInfo;
vInfo(1).B = eye(3);
vInfo(2).B = [eye(2); 1 1];
vInfo(3).B = [eye(4); 1 0 0 1];

vInfo = errCheck(vInfo);

%% Conditioning
checkVars1 = [3 1 4]; checkStates1 = [3 1 3];
checkVars2 = [1 3]; checkStates2 = [1 1];
checkVars3 = [2]; checkStates3 = 2;

compatFlag1 = isCompatible(M(1).C,M(1).variables,checkVars1,checkStates1,vInfo);
compatFlag2 = isCompatible(M(1).C,M(1).variables,checkVars2,checkStates2,vInfo);
compatFlag3 = isCompatible(M(1).C,M(1).variables,checkVars3,checkStates3,vInfo);

[Mcond1,vInfo] = condition(M,checkVars1,checkStates1,vInfo);
[Mcond2,vInfo] = condition(M,checkVars2,checkStates2,vInfo);
[Mcond3,vInfo] = condition(M,checkVars3,checkStates3,vInfo);
%{
% Correct result:
Mcond1: (1) [1 1 3;1 2 3];[.2;.1] (2) [1;2];[.3;.7] (3) [3];[.3]
Mcond2: (1) [1 3 1];[.7] (2) [1;2];[.3;.7] (3) [1];[.1]
Mcond3: (1) [1 2 5;2 2 5;3 2 5;1 2 2;2 2 2;3 2 2;1 2 3;3 2 3];[.7;.2;.1;.5;.2;.3;.1;.9] (2) [2];[.7] (3) [1;2;3;4];[.1;.2;.3;.4]
%}

%% Product
Mprod1 = product(M(1),M(2),vInfo);
Mprod2 = product(M(1),M(3),vInfo);
Mprod3 = product(M(2),M(3),vInfo);

%{
% Correct result:
Mprod1: [1 1 2;2 1 2;1 1 3;3 1 3;1 2 2;2 2 2;3 2 2;1 2 3;3 2 3;1 1 5;2 1 5;3 1 5;1 2 5;2 2 5;3 2 5];[.18;.12;.35;.14;.21;.06;.24;.07;.63;.21;.06;.03;.49;.14;.07]
Mprod2: [1 2 1;2 2 1;1 3 1;3 3 1;1 2 2;2 2 2;3 2 2;1 3 2;3 3 2;1 1 3;2 1 3;3 1 3;1 4 3;2 4 3;3 4 3];[.12;.08;.06;.24;.1;.04;.06;.03;.27;.07;.02;.01;.28;.08;.04]
Mprod3: [1 1;2 1;1 2;2 2;1 3;2 3;1 4;2 4];[.03;.07;.06;.14;.09;.21;.12;.28]
%}

%% Sum
Msum1 = sum(Mprod1,[2 4],0);
Msum2 = sum(Mprod2,[3 2]);
Msum3 = sum(Mprod3,[3 2 1],1);

%{
% Correct result:
Msum1: [1 2;2 2;1 3;2 3;1 5;2 5];[.3;.7;.3;.7;.3;.7]
Msum2: [1 2;2 1;3 1;1 2;2 2;3 2;1 3;2 3;3 3];[.18;.08;.24;.13;.04;.33;.35;.1;.05]
Msum3: [];[1]
%}
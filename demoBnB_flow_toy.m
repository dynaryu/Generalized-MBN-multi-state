clear;
import gmbn.*

flags = [0 1 2]; % branch's flag: [unspecified survival failure]
targetUnspecGap = 0;

arcs = [1 2;1 4;2 3;4 2;4 3;5 4];
sNode=1; tNode=3; targetFlow=5;
arcsCapas{1}=[0 2 4]; arcsProbs{1}=[.1 .2 .7];
arcsCapas{2,1}=[0 2 3]; arcsProbs{2,1}=[.1 .3 .6];
arcsCapas{3}=[0 3]; arcsProbs{3}=[.2 .8];
arcsCapas{4}=[0 2]; arcsProbs{4}=[.1 .9];
arcsCapas{5}=[0 2 4]; arcsProbs{5}=[.2 .3 .5];
arcsCapas{6}=[0 2 4]; arcsProbs{6}=[.1 .4 .5];

[arcs,arcsCapas,arcsProbs] = sortArcs(arcs,arcsCapas,arcsProbs);

[branches,flagWeight] = BnB_flow( arcs,arcsCapas,arcsProbs,sNode,tNode,targetFlow,flags,targetUnspecGap );

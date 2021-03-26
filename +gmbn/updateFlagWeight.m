function [flagWeight,decompFlagWeight] = updateFlagWeight(flagWeight,oldFlagWeight,newFlagWeight,decompFlagIdx)

flagWeight = flagWeight - oldFlagWeight + newFlagWeight;
decompFlagWeight = flagWeight( decompFlagIdx );
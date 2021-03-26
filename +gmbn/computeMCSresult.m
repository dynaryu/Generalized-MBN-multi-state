function [mean,cov] = computeMCSresult(numSamp,numDetect)

mean = numDetect / numSamp;

if numDetect > 1 && ( numSamp - numDetect > 1)
    std = sqrt( (1-mean)*mean/numSamp );
    cov = std/mean;
else
    cov = 1;
end
function std = getStd_Campbell97( logAh )
%{
Evaluate standard deviation of log(Ah) 
Ref: Campbell (1997)
%}

if exp( logAh ) < .068
    std = .55;
elseif exp( logAh ) <= .21
    std = .173-.140*logAh;
else
    std = .39;
end
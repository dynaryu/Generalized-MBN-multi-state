function obj_norm = myNormalize(obj)

if sum(obj<0)
    error('Elements must be nonnegative')
else
    obj_norm = exp( log(obj)-log(sum(obj)) );
end
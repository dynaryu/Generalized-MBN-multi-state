classdef sampling
    
    properties
        realization
        state
        sampleWeight
    end
    
    methods
        function sample = sampling(realization,state,sampleWeight)
            if nargin > 0
                sample.realization = realization;
                if nargin > 1
                    sample.state = state;
                    if nargin > 2
                        sample.sampleWeight = sampleWeight;
                    end
                end
            end
        end
    end
end


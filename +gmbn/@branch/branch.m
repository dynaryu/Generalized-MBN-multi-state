classdef branch
    
    properties
        lowBound
        upBound        
        weight
        flag
    end
    
    methods
        function br = branch( lowBound,upBound,weight,flag )
            if nargin > 0
                br.upBound = upBound;
                br.lowBound = lowBound;
                br.weight = weight;
                br.flag = flag;
                [br,errFlag,errMess] = errCheckBranch(br);
                if errFlag
                    error(errMess);
                end
            end
        end
        
        function [br,errFlag,errMess] = errCheckBranch(br)
            errFlag = 0;
            errMess = '';
            if length(br.upBound)~=length(br.lowBound)
                errFlag = 1;
                errMess = 'upBound and lowBound must have the same length';
            elseif ~isempty(br.weight) && ~isscalar(br.weight) 
                errFlag = 1;
                errMess = 'weight must be a numerical scalar';
            end
        end
    end
    
end
                
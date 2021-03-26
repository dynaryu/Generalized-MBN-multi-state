classdef cpm
    
    properties
        variables
        numChild
        C % event matrix
        p % probability vector
    end
    
    methods
        function M = cpm(variables,numChild,C,p)
            if nargin>0
                M.variables=variables(:)';
                if nargin>1
                    M.numChild = numChild;
                    if nargin>2
                        M.C = C;
                        if nargin>3
                            M.p = p(:);
                        end
                    end
                end
            end
            [M,errFlag,errMess] = errCheckCpm(M);
            if errFlag
                error(errMess);
            end
        end
            
        function [M,errFlag,errMess] = errCheckCpm(M)
            errFlag = 0;
            errMess = '';
            if ~isempty(M.variables) && ~isnumeric(M.variables)
                errFlag = 1;
                errMess = 'variables must be a numeric vector';
            elseif ~isempty(M.numChild) && (~isnumeric(M.numChild)||~isscalar(M.numChild))
                errFlag = 1;
                errMess = 'numChild must be a numeric scalar';
            elseif (~isempty(M.numChild)&&~isempty(M.variables)) && (M.numChild>length(M.variables))
                errFlag = 1;
                errMess ='numChild must be greater than the number of variables';
            elseif ~isempty(M.C) && ~isnumeric(M.C)
                errFlag = 1;
                errMess = 'Event matrix C must be a numeric matrix';
            elseif (~isempty(M.C)&&~isempty(M.variables)) && (size(M.C,2)~=length(M.variables))
                errFlag = 1;
                errMess ='C must have the same number of columns with that of variables';
            elseif ~isempty(M.p) && ~isnumeric(M.p)
                errFlag = 1;
                errMess ='Probability vector p must be a numeric vector';
            elseif (~isempty(M.p)&&~isempty(M.C)) && (length(M.p)~=size(M.C,1))
                errFlag = 1;
                errMess = 'p must have the same length with the number of rows in C';
            end                
        end

    end
end
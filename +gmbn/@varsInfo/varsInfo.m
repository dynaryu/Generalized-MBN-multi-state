classdef varsInfo
    
    properties
        B % basis set
        v % description of states
    end
    
    methods
        function vInfo = varsInfo(B,v)            
            if nargin>0          
                if ismatrix(B)
                    vInfo.B=B;
                elseif iscell(B)
                    vInfo.B=B(:);
                else
                    error('B must be either a matrix (given one variable) or a cell (multiple variables)')
                end
                    
                if nargin>1
                    vInfo.v=v;
                end
            end            
            [vInfo,errFlag,errMess] = errCheckVarsInfo(vInfo);
            if errFlag
                error(errMess);
            end
        end
        
        function [vInfo,errFlag,errMess] = errCheckVarsInfo(vInfo)
            errFlag = 0;
            errMess = '';
            if ~isempty(vInfo.B)
                numBasicState = size(vInfo.B,2);
                if ~isequal( vInfo.B(1:numBasicState,:),eye(numBasicState) )
                    errFlag = 1;
                    errMess = 'The upper part corresponding to basic states must form an identity matrix';
                end 
%                 if ~isempty(vInfo.v)
%                     if size(vInfo.v,1)~=size(vInfo.B,2)
%                         errFlag = 1;
%                         errMess = 'The number of rows of v (described states) must be the same with the number of columns in B';
%                     end 
%                 end
            end
        end
 
    end
end
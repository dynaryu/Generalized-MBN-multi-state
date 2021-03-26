function obj = errCheck(obj)

import gmbn.*

obj = obj(:);

if isa(obj,'cpm')
    for ii = 1:length(obj)
        obj_i = obj(ii);
        [obj_i,errFlag,errMess] = errCheckCpm(obj_i);
        if errFlag
            error(['cpm(' num2str(ii) '): ' errMess])
        else
            if ~isempty(obj_i.variables)
                obj_i.variables = obj_i.variables(:)';
            end
            if ~isempty(obj_i.p)
                obj_i.p = obj_i.p(:);
            end
            obj(ii) = obj_i;
        end
    end
elseif isa(obj,'varsInfo')
    for ii = 1:length(obj)
        [obj(ii),errFlag,errMess] = errCheckVarsInfo(obj(ii));
        if errFlag
            error(['varsInfo(' num2str(ii)  '): ' errMess])
        end
    end
else
    error('errCheck function works only for classes "cpm" and "varsInfo"')
end
    
disp('No error detected in given CPMs')

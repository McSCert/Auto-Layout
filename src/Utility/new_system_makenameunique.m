function name = new_system_makenameunique(baseName, varargin)
% Use varargin to pass additional arguments to the new_system command

cont = true;
name = baseName;
count = 0;
while cont
    try
        new_system(name,'ErrorIfShadowed',varargin{:})
        cont = false;
    catch ME
        if strcmp(ME.identifier,'Simulink:Commands:NewSysAlreadyExists')
            count = count + 1;
            name = [baseName, num2str(count)];
            cont = true;
        else
            rethrow(ME)
        end
    end
end
end
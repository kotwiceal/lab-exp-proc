function poolobj = poolswitcher(resources, poolsize)
    %% Change the current pool context if the new configuration is different from the previous one.

    arguments
        resources {mustBeMember(resources, {'Processes', 'Threads', 'backgroundPool'})}
        poolsize (1,:) double {mustBeInteger}
    end

    poolobj = gcp('nocreate');
    label = [];
    if isempty(poolsize)
        arg = {resources};
    else
        arg = {resources, poolsize};
    end

    switch class(poolobj)
        case 'parallel.Pool'
            try
                if strcmp(resources, "backgroundPool")
                    poolobj = backgroundPool;
                    label = [];
                else
                    if isempty(getCurrentWorker)
                        poolobj = parpool(arg{:});
                    end
                end
            catch
            end
        case 'parallel.ThreadPool'
            label = "Threads";
        case 'parallel.ProcessPool'
            label = "Processes";
    end
    if ~isempty(label)
        if (resources ~= label) || (poolsize ~= poolobj.NumWorkers)
            delete(gcp('nocreate'));
            poolobj = parpool(arg{:});
        end
    end

end
function poolobj = poolswitcher(resources, poolsize)
    %% Change the current pool context if the new configuration is different from the previous one.

    arguments
        resources {mustBeMember(resources, {'Processes', 'Threads', 'backgroundPool'})}
        poolsize
    end

    poolobj = gcp('nocreate');
    label = [];

    switch class(poolobj)
        case 'parallel.Pool'
            try
                if resources ~= "backgroundPool"
                    if isempty(getCurrentWorker)
                        poolobj = parpool(resources, poolsize);
                    end
                else
                    poolobj = backgroundPool;
                    label = [];
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
            poolobj = parpool(resources, poolsize);
        end
    end

end
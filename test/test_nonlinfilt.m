%%
[result, mask] = nonlinfilt(@(x,~)mean(x(:)), rand(20,20,5), ...
    kernel = [1, nan, nan], stride = [2, 2, 1], offset = [-3, 0], ...
    isfiltpass = true, verbose=true, cast = 'int16');
%%


%%
clc
kwargs = struct;
kwargs.szarg = {[20,20,3],[20,20,3]};
kwargs.kernel = [nan, nan, 1];
kwargs.stride = [1,1,1];
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
% kwargs.padval = {true, true, true};
kwargs.padval = [];

arg = namedargs2cell(kwargs);
kwargs = filteval(arg{:});

viewfiltpass2(kwargs.filtpass, 4, pause = 1e-3);
%%
clear; clc;
[result, mask] = nonlinfilt(@(x)mean(x(:)), rand(20,20,2), ...
    kernel = [3, 3], stride = [1, 1], offset = [0, 0], ...
    isfiltpass = true, shape = 'same', verbose=true, cast = 'int16', ...
    ispad={{0,0,0}});
clearAllMemoizedCaches
%
viewfiltpass2(mask, 4, pause = 1e-3);
%%
clear; clc;
[result, mask] = nonlinfilt(@(x)mean(x(:)), rand(20,20,5), ...
    kernel = [1, nan, nan], stride = [2, 2, 1], offset = [-3, 0], ...
    isfiltpass = true, shape = 'same', verbose=true, cast = 'int16');
clearAllMemoizedCaches
%
viewfiltpass2(mask, 4, pause = 1e-3);
%%
opts.padval = {{10, nan, "symmetrical", "none"}}
opts.padvalbool = {};
for i = 1:numel(opts.padval)
    for j = 1:numel(opts.padval)
        if opts.padval{i}{j} == "none"
            flag = true;
        else
            flag = false;
        end
        opts.padvalbool{i}(j) = flag;
    end
end
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 0, stride = 1, offset = 0, ...
    filtpass = true, shape = 'same');
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 0, stride = 1, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-3)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 1, stride = 1, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 5, stride = 1, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 4, stride = 1, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,21);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 5, stride = 1, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,21);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 4, stride = 1, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 5, stride = 2, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 5, stride = 3, offset = 0, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 5, stride = 3, offset = 3, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 5, stride = 3, offset = -3, ...
    filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 1, stride = 1, offset = 0, ...
    filtpass = true, shape = 'valid');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 3, stride = 1, offset = 0, ...
    filtpass = true, shape = 'valid');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = 5, stride = 2, offset = 0, ...
    filtpass = true, shape = 'valid');
viewfiltpass(mask, 4, pause = 1e-1)
%%
x1 = rand(1,20);
x2 = rand(1,20);
[~, mask] = nonlinfilt(x1, x2, method = @(x1,x2) rms(x1.*x2), ...
    kernel = 3, stride = 1, filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x1 = rand(1,20);
x2 = rand(1,20);
[~, mask] = nonlinfilt(x1, x2, method = @(x1,x2) rms(x1.*x2), ...
    kernel = 3, stride = 1, filtpass = true, shape = 'valid');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @(x) [rms(x), mean(x)], ...
    kernel = 5, filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(1,20);
[~, mask] = nonlinfilt(x, method = @(x) [rms(x), mean(x)], ...
    kernel = 5, filtpass = true, shape = 'valid');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, 3], ...
    stride = [1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-3)
%%
x = rand(21);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, 3], ...
    stride = [1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-3)
%%
x = rand(20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, 3], ...
    stride = [1, 1], filtpass = true, shape = 'valid');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(21);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, 3], ...
    stride = [1, 1], filtpass = true, shape = 'valid');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, nan], ...
    stride = [1, nan], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, nan], ...
    stride = [1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, 0], ...
    stride = [1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, 0], ...
    stride = [1, nan], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x = rand(20);
[~, mask] = nonlinfilt(x, method = @rms, kernel = [6, 0], ...
    stride = [1, 2], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-2)
%%
x1 = rand(20);
x2 = rand(20);
[~, mask] = nonlinfilt(x1, x2, method = @(x1,x2) [rms(x1.*x2), mean(x1.*x2)], ...
    kernel = [5, 3], stride = [1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 3, pause = 1e-4)
%%
x1 = rand(20);
x2 = rand(20);
[~, mask] = nonlinfilt(x1, x2, method = @(x1,x2) [rms(x1.*x2), mean(x1.*x2)], ...
    kernel = [5, 3], stride = [1, 1], filtpass = true, shape = 'valid');
viewfiltpass(mask, 3, pause = 1e-4)
%%
x = rand(20,20,6);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, 3], ...
    stride = [1, 1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-4)
%%
x = rand(20,20,6);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, 3], ...
    stride = [1, 1, 1], filtpass = true, shape = 'valid');
viewfiltpass(mask, 4, pause = 1e-4)
%%
x = rand(20,20,3);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, 0], ...
    stride = [1, 1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-4)
%%
x = rand(20,20,3);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, 1], ...
    stride = [1, 1, 1], filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-4)
%%
x = rand(20,20,3);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, 1], ...
    stride = [1, 1, nan], filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-4)
%%
x = rand(20,20,3);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, 0], ...
    stride = [1, 1, 1], filtpass = true, shape = 'valid');
viewfiltpass(mask, 4, pause = 1e-4)
%%
x = rand(20,20,5);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, nan], ...
    stride = [1, 1, nan], filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-5)
%%
x = rand(20,20,5);
[~, mask] = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, nan], ...
    stride = [1, 1, nan], filtpass = true, shape = 'valid');
viewfiltpass(mask, 4, pause = 1e-5)
%%
x1 = rand(20,20,2);
x2 = rand(20,20,2);
[~, mask] = nonlinfilt(x1, x2, method = @(x1,x2)rms(x1(:)).*rms(x2(:)), ...
    kernel = {[5, 5, nan], [10, 10, nan]}, stride = [1, 1, nan], filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-5)
%%
x1 = rand(20,20,3);
x2 = rand(20,20,5);
[~, mask] = nonlinfilt(x1, x2, method = @(x1,x2)rms(x1(:)).*rms(x2(:)), ...
    kernel = {[5, 5, nan], [10, 10, nan]}, stride = [1, 1, nan], filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-5)
%%
x1 = rand(20,20,3);
x2 = rand(20,20,6);
[~, mask] = nonlinfilt(x1, x2, method = @(x1,x2)rms(x1(:)).*rms(x2(:)), ...
    kernel = {[5, 5, 3], [10, 10, 5]}, stride = {[1, 1, 1], [1, 1, 2]}, filtpass = true, shape = 'same');
viewfiltpass(mask, 4, pause = 1e-5)
%% support functions
function viewfiltpass(mask, nker, kwargs)
    arguments
        mask (1,:) cell
        nker (1,1) double
        kwargs.pause (1,1) double = 1e-3
    end
    mask = cellfun(@double,mask,UniformOutput=false);
    clf; tl = tiledlayout('flow'); ax = cell(1, numel(mask));
    for i = 1:numel(mask); ax{i} = nexttile(tl); end
    for i = 1:size(mask{1}, nker)
        for j = 1:numel(mask)
            cla(ax{j})
            switch nker
                case 1
                    imagesc(ax{j}, mask{j}(:,i));
                case 2
                    imagesc(ax{j}, mask{j}(:,:,i));
                case 3
                    imagesc(ax{j}, mask{j}(:,:,i));
                otherwise
                    imagesc(ax{j}, imtile(mask{j}(:,:,:,i), GridSize = [nan, 1]));
            end
            axis(ax{j}, 'image');
            drawnow; 
        end
        pause(kwargs.pause);
    end
end

function viewfiltpass2(mask, nker, kwargs)
    arguments
        mask (1,:) cell
        nker (1,1) double
        kwargs.pause (1,1) double = 1e-3
    end
    % mask = cellfun(@double,mask,UniformOutput=false);
    clf; tl = tiledlayout('flow'); ax = cell(1, numel(mask));
    for i = 1:numel(mask{1}) ax{i} = nexttile(tl); end
    for i = 1:numel(mask)
        for j = 1:numel(mask{i})
            mask{i}{j} = double(mask{i}{j});
            cla(ax{j})
            imagesc(ax{j}, imtile(mask{i}{j}, GridSize = [nan, 1]));
            % switch nker
            %     case 1
            %         imagesc(ax{j}, mask{i}{j});
            %     case 2
            %         imagesc(ax{j}, mask{j}(:,:,i));
            %     case 3
            %         imagesc(ax{j}, mask{j}(:,:,i));
            %     otherwise
            %         imagesc(ax{j}, imtile(mask{j}(:,:,:,i), GridSize = [nan, 1]));
            % end
            axis(ax{j}, 'image');
            drawnow; 
        end
        pause(kwargs.pause);
    end
end
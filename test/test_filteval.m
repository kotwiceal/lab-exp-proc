%% data 1D
[~, filtpass] = filteval(szarg = [10, 1], kernel = 1, isfiltpass = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 1], kernel = 3, isfiltpass = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 1], kernel = 3, isfiltpass = true, padval = false);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 1], kernel = [3, 1], isfiltpass = true, padval = false);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 1], kernel = [3, 1], isfiltpass = true, padval = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 1], kernel = [3, 1], isfiltpass = true, padval = {true, false});
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 1], kernel = [3, 1], isfiltpass = true, padval = {false, true});
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = [3, 1], isfiltpass = true, padval = false);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = [3, 1], isfiltpass = true, padval = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = [3, 1], isfiltpass = true, padval = true, slice = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = 3, isfiltpass = true, ...
    padval = true, slice = false, filtdim = 1);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = 3, isfiltpass = true, ...
    padval = true, slice = true, filtdim = 2);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = [3, 1], isfiltpass = true, ...
    padval = true, slice = false, filtdim = [1, 2]);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = [3, 1], isfiltpass = true, ...
    padval = true, slice = true, filtdim = [1, 2]);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = 3, isfiltpass = true, ...
    padval = false, slice = true, filtdim = 1);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = 3, isfiltpass = true, ...
    padval = true, slice = true, filtdim = 1);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = 3, isfiltpass = true, ...
    padval = {true, false}, slice = true, filtdim = 1);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = 3, isfiltpass = true, ...
    padval = true, slice = true, filtdim = 1);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [10, 2], kernel = 3, isfiltpass = true, ...
    padval = true, slice = true, filtdim = 1);
viewfilteval(filtpass);
%%
%
%
%
%% data 1D
[~, filtpass] = filteval(szarg = [1, 10], kernel = [1, 1], isfiltpass = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [1, 10], kernel = [1, 3], isfiltpass = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [1, 10], kernel = [1, 3], isfiltpass = true, padval = false);
viewfilteval(filtpass);
%%
%
%
%
%% data 1D
[~, filtpass] = filteval(szarg = [10, 10], kernel = [1, 1], isfiltpass = true);
viewfilteval(filtpass);
%%
%
%
%
%% data 2D
[~, filtpass] = filteval(szarg = [10, 10, 10], kernel = [3, 3, nan], ...
    isfiltpass = true, padval = {nan,nan,false});
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [1, 10], kernel = [1, 3], isfiltpass = true, verbose = true);
viewfilteval(filtpass);
%% data 1D
[~, filtpass] = filteval(szarg = [1, 10], kernel = [1, 2], isfiltpass = true, verbose = true);
viewfilteval(filtpass);
%% data 3D, 2 arg
kwargs = struct;
kwargs.szarg = {[20,20,3],[20,20,3]};
kwargs.kernel = [nan, nan, 1];
kwargs.stride = [1,1,1];
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass] = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 3D, 2 arg 
kwargs = struct;
kwargs.szarg = {[20,20,3],[20,20,3]};
kwargs.kernel = [nan, nan, 1];
kwargs.stride = [1,1,1];
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass] = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 1D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 1], [20, 1]};
kwargs.kernel = [2, 1];
kwargs.stride = [1, 1];
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 1D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 1], [20, 1]};
kwargs.kernel = [2, 1];
kwargs.stride = [1, 1];
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 1D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 1], [20, 1]};
kwargs.kernel = {[2, 1], [2, 1]};
kwargs.stride = [1, 1];
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 1D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 1], [20, 1]};
kwargs.kernel = {[3, 1], [3, 1]};
kwargs.stride = {[2, 1], [2, 1]};
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 2D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 20], [20, 20]};
kwargs.kernel = {[3, 1], [3, 1]};
kwargs.stride = {[2, 1], [2, 1]};
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 2D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 20], [20, 20]};
kwargs.kernel = {[4, 4], [4, 4]};
kwargs.stride = {[1, 1], [1, 1]};
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = false;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 2D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 20], [20, 20]};
kwargs.kernel = {[4, 4], [4, 4]};
kwargs.stride = {[2, 2], [2, 2]};
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = false;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 2D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 20], [20, 20]};
kwargs.kernel = {[3, 3], [3, 3]};
kwargs.stride = {[2, 2], [2, 2]};
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = false;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 2D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 20], [20, 20]};
kwargs.kernel = {[4, 4], [4, 4]};
kwargs.stride = {[1, 1], [1, 1]};
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%% data 2D, 2 arg
kwargs = struct;
kwargs.szarg = {[20, 20], [20, 20]};
kwargs.kernel = {[4, 4], [4, 4]};
kwargs.stride = {[1, 1], [1, 1]};
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = {{true,false},{true,false}};

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%%
%
%
%
%%
kwargs = struct;
kwargs.szarg = [100,100];
kwargs.kernel = repmat(5,20,20);
kwargs.stride = repmat(1,20,20);
kwargs.offset = [];
kwargs.cast = 'int16';
kwargs.isfiltpass = true;
kwargs.padval = true;

arg = namedargs2cell(kwargs);
[~, filtpass]  = filteval(arg{:});

viewfilteval(filtpass, pause = 1e-3);
%%
function viewfilteval(mask, kwargs)
    arguments
        mask cell {mustBeVector}
        kwargs.pause (1,1) double = 1e-3
    end

    clf; tl = tiledlayout('flow'); ax = cell(1, numel(mask{1}));
    for i = 1:numel(mask{1}) ax{i} = nexttile(tl); end
    for i = 1:numel(mask)
        for j = 1:numel(mask{i})
            mask{i}{j} = double(mask{i}{j});
            cla(ax{j});
            imagesc(ax{j}, imtile(mask{i}{j}, GridSize = [1, nan]));
            axis(ax{j}, 'image'); set(ax{j}, 'XTickLabels', [], 'YTickLabels', [])
            title(ax{j}, "window-"+num2str(j));
            drawnow; 
        end
        pause(kwargs.pause);
    end
end
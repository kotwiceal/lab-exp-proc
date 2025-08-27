function varargout = calibcta(varargin, kwargs)
    %% Calibrate hot-wire/film sensor.

    arguments (Input, Repeating)
        varargin
    end

    arguments (Input)
        %% processing
        kwargs.sensor (1,:) char {mustBeMember(kwargs.sensor, {'wire', 'film'})} = 'wire'
        kwargs.y (:,:) double = [] % wall position
        kwargs.u0 (1,:) double = [] % inflow velocity
        kwargs.index (1,:) double = 1:2 % node index to poly1 fit
        %% appearance
        kwargs.show (1,1) logical = true % display results
        kwargs.docked (1,1) logical = false % dock figure
        kwargs.title (1,:) char = []
    end

    arguments (Output, Repeating)
        varargout
    end

    switch kwargs.sensor
        case 'wire'
            probe = varargin{1};
            velocity = varargin{2};
            filename = varargin{3};

            probe = str2num(strrep(probe,',','.'));
            writematrix([probe; velocity]', filename, 'Delimiter', 'tab')
        
            % replace dot by comma
            tmp = fileread(filename);
            tmp = strrep(tmp, '.', ',');
            fid = fopen(filename, 'w');
            fwrite(fid, tmp, 'char');
            fclose(fid);

        case 'film'
            wire = varargin{1}; % dims = [sample, wall position, inflow velocity];
            film = varargin{2}; % dims = [sample, channel, inflow velocity];

            wire = squeeze(mean(wire,1));
            film = squeeze(mean(film,1));

            kwargs.yunit = true;
            kwargs.u0isloc = false;

            if isempty(kwargs.y); kwargs.y = repmat((1:size(wire,1))',1,size(wire,2)); kwargs.yunit = false; end
            if isempty(kwargs.u0); kwargs.u0 = max(wire, [], 1); kwargs.u0isloc = true; end

            % show velocity profiles
            if kwargs.show
                if kwargs.docked; figure(WindowStyle = 'docked'); else; figure; end
                tiledlayout('flow');
                nexttile; hold on; box on; grid on; axis square;
                plt = plot(kwargs.y, wire,'.-');
                scatter(kwargs.y(kwargs.index,:), wire(kwargs.index,:), 'filled');
                if kwargs.yunit; xlabel('y, mm'); else; xlabel('y_n'); end
                ylabel('u, m/s');
                l = legend(plt, num2str(round(kwargs.u0',1)),Location='eastoutside');
                if kwargs.u0isloc
                    title(l, 'U_e, m/s', FontWeight = 'normal');
                else 
                    title(l, 'U_0, m/s', FontWeight = 'normal');
                end
                title('wire', FontWeight = 'normal');
                if ~isempty(kwargs.title); sgtitle(kwargs.title); end
            end

            dudy = zeros(1, size(wire, 2));
            for i = 1:numel(dudy)
                [x0, y0] = prepareCurveData(kwargs.y(kwargs.index, i)*1e-3, wire(kwargs.index, i));
                ufit = fit(x0, y0, 'poly1');
                dudy(i) = ufit.p1;
            end

            % piecewise linear fit
            fit_dudy = cell(1, size(film, 1));
            for i = 1:size(film, 1)
                try
                    [x0, y0] = prepareCurveData(film(i,:), dudy);
                    fit_dudy{i} = fit(x0, y0, 'linearinterp');
                catch
                    warning(num2str(i) + "-channel isn`t calibrated")
                end
            end

            varargout{1} = fit_dudy;

            % show calibration
            if kwargs.show
                if kwargs.docked; figure(WindowStyle = 'docked'); else; figure; end
                tiledlayout('flow');
                nexttile; hold on; box on; grid on; axis square;
                for i = 1:size(film, 1)
                    plot(dudy, film(i,:), '.-', DisplayName = num2str(i));
                end
                l = legend(Location = 'eastoutside'); title(l, 'channel', FontWeight = 'normal');
                ylabel('voltage'); 
                if kwargs.yunit; xlabel('du/dy, 1/s'); else; xlabel('du/dy_n'); end
                title('film', FontWeight = 'normal');
                if ~isempty(kwargs.title); sgtitle(kwargs.title); end
            end

    end

end
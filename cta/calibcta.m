function calibcta(prb, vel, fln)
    %% Create CTA calibration file.

    arguments
        prb (1,:) string % probe vector
        vel (1,:) double % velocity vector
        fln (1,:) string % filename
    end

    prb = str2num(strrep(prb,',','.'));
    writematrix([prb; vel]', fln, 'Delimiter', 'tab')

    % replace dot by comma
    tmp = fileread(fln);
    tmp = strrep(tmp, '.', ',');
    fid = fopen(fln, 'w');
    fwrite(fid, tmp, 'char');
    fclose(fid);

end
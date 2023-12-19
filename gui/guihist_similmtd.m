function [roi1, roi2] = guihist_similmtd(axroi, data, shape, type_norm, range)
%% Visualize statistics data and apply similarity statistics criteria by means manually two box selection.
%% The function takes following arguments:
%   axroi:  [axes object]       - axis object of canvas that selection data events are being occured
%   data:   [n×m... double]     - multidimensional data
%   shape:  [1×2 double]        - box selection size
%   type_norm [char array]      - type pf statistic normalization
%   range:          [1×2 double]        - specified range to cut data{}

    seldata = @(roiobj) giuhistselect(roiobj, data, type_norm, range);

    function plotevent(src, evt)
        axloc = src.UserData.ax;
        roiobj = src.UserData.roiobj;
        seldataloc = src.UserData.seldata;

        [edges1, counts1] = seldataloc(evt.Source);
        [edges2, counts2] = seldataloc(roiobj);

        [edges1, counts1, edges2, counts2, edgesgl, f1s, f2s, f12s] = histsimilarfactor(edges1, counts1, edges2, counts2);

        src.UserData.edges = edgesgl;
        src.UserData.counts = f1s;

        roiobj.UserData.edges = edgesgl;
        roiobj.UserData.counts = f2s;

        cla(axloc); hold(axloc, 'on'); box(axloc, 'on'); grid(axloc, 'on');
        plot(axloc, edges1, counts1, '-o', 'Color', src.UserData.color)
        plot(axloc, edges2, counts2, '-o', 'Color', roiobj.UserData.color)

        plot(axloc, edgesgl, f1s, 'LineWidth', 2, 'Color', src.UserData.color)
        plot(axloc, edgesgl, f2s, 'LineWidth', 2, 'Color', roiobj.UserData.color)
        plot(axloc, edgesgl, f12s, 'LineWidth', 2)

    end

    [roi1, roi2] = guiriopairrect(axroi, shape, seldata, @plotevent);

end
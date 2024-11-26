%% Description
% This is a MATLAB function named `gridcta` that generates a scanning grid to measure using a single hot-wire sensor moved by 3-axis traverse. The function takes several input arguments and optional keyword arguments to customize its behavior.
% 
% Here's a breakdown of the function's functionality:
% 
% 1. **Input arguments**: The function accepts two types of input arguments:
% 	* `varargin`: a vector of position vectors for each axis, which defines the scanning grid.
% 	* `kwargs`: an optional set of key-value pairs that can be used to customize the behavior of the function.
% 2. **Keyword arguments**:
% 	* `order`: specifies the order of the axes in the scanning grid (default: 1:nargin).
% 	* `orderflip`: flips the axis order (default: true).
% 	* `offset`: a cell array containing offsetting points for each axis (default: empty).
% 	* `offsetdim`: specifies the dimension to apply the offset (default: 3).
% 	* `show`: shows the scan grid plot.
% 	* `dock`: docks the figure window (default: false).
% 	* `markersize`: sets the marker size for the scatter plot (default: 5).
% 	* `delimiter`: sets the delimiter for exporting data to a matrix file (default: ',').
% 3. **Function body**:
% 	* The function first checks if the `show` keyword argument is set to true.
% 	* If `show` is true, it creates a figure window and displays the scan grid plot using `tiledlayout`, `scatter3`, and other plotting functions.
% 	* It also adds some visual elements to the plot, such as labels, legend, and axis limits.
% 	* The function then parses the output values into separate variables and exports them to a matrix file or saves them to a MAT file.
% 4. **Output**:
% 	* The function returns three output variables:
% 		+ `scan`: the scanning grid data in 3D format (a matrix).
% 		+ `scanoffset`: the offsetted scan data in 3D format (a matrix).
% 		+ `fitobj` (optional): a fit object containing the results of the curve or surface fitting.
% 
% The function is designed to be flexible and customizable, allowing users to adjust various parameters to suit their specific needs. However, its complexity and number of options may make it challenging for casual users to fully understand and use effectively.
% 

%% Examples
% This section presents several examples of the usage of grid generation
% for multi-axis traverse actuator.
%% Create a 1D scan grid at 3-axis measurement and save into scan_ax1fix_ax2fix_ax3var.txt
scan = gridcta(0, 0, 0:50:1000, filename = 'docs\src\gridcta\scan_ax1fix_ax2fix_ax3var')
%% Create a 2D scan grid at 3-axis measurement.
scan = gridcta(0, -3000:500:3000, 0:50:1000)
%% Create a 3D scan grid at 3-axis measurement.
scan = gridcta(0:200:1000, -3000:500:3000, 0:50:1000)
%% Create a 1D scan grid with optional axis at 3-axis measurement.
scan = gridcta(0, 0, 200:100:1000, 0:1)
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly02` law.
[scan, scanoffset, fitobj] = gridcta(0, -1000:500:1000, 200:100:1000, ...
    offset = {0, [-1000, -800, -400, 0, 400, 800, 1000], [-425, -356, -314, -300, -314, -356, -425]}, ...
    fit = 'poly02')
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly22` law.
[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...
    offset = {[0, 250, 500], [-1200, -400, 400, 1200], ...
    [-425, -314, -314, -425, -325, -303, -303, -325, 275, 297, 297, 275]}, ...
    fit = 'poly22')
%% Create a 2D scan grid at 3-axis measurement with changing axis scan order.
scan = gridcta(0:200:1000, -3000:500:3000, 500, order = [1, 2, 3])
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-2 by `poly1` and axis-3 by `poly22` laws correspondingly.
offset = {{[0, 1000], [0, 5000], []}; ...
    {[0, 250, 500], [-1200, -400, 400, 1200], [-425, -314, -314, -425, -325, -303, -303, -325, 275, 297, 297, 275]}};

[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...
    offset = offset, offsetdim = [2, 3],  ...
    fit = {'poly1', 'poly22'})
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-1 by `linearinterp` law.
[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...
    offset = {[0, 100, 200], [0, 200, 600], []}, offsetdim = 1,  ...
    fit = 'linearinterp')
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law.
[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...
    offset = {[], [0, 100], [0, 500]}, offsetdim = 3,  ...
    fit = 'poly1')
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law.
[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...
    offset = {[0, 100], [], [0, 500]}, offsetdim = 3,  ...
    fit = 'poly1')

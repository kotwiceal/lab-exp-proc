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

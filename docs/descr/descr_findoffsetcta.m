%% Description
% This is a MATLAB function named `findoffsetcta` that appears to be used for analyzing scan data from a CT scanner. The function takes several input arguments and returns three output values: `y0`, `z0`, and `x0`.
% 
% **Input Arguments**
% 
% The function accepts the following input arguments:
% 
% * `filename`: the path to a file or folder containing the scan data (e.g., a CSV or text file).
% * `kwargs` (optional): an optional structure that contains various parameters controlling the analysis.
% 
% Some of the key input arguments include:
% 
% * `scandelimiter` and `scanseparator`: character strings specifying how the scan data is separated.
% * `numch`: an integer specifying the number of channels in the scan data.
% * `isovel`: a scalar value representing the cutoff velocity for exclusion.
% * `y`, `yi`, `ratio`: vectors or arrays controlling the analysis, such as initial approximations and dimensionless velocity values.
% * `reshape`: a vector specifying how to reshape the scan data into a gridwise format.
% * `show` and `docked`: logical values controlling whether to display results.
% 
% **Function Flow**
% 
% Here's a high-level overview of the function flow:
% 
% 1. **Input validation**: The function checks if the input file or folder exists, and loads the scan data accordingly.
% 2. **Data extraction**: The function extracts relevant columns from the scan data (e.g., `y`, `z`, `v`).
% 3. **Exclusion**: The function excludes points with velocities below the specified cutoff value (`isovel`).
% 4. **Piecewise linear interpolation**: The function applies piecewise linear interpolation to each column of the remaining data.
% 5. **Offset calculation**: The function calculates the offset values using the `fsolve` function, which requires initial approximations (`yi`) and dimensionless velocity values (`ratio`).
% 6. **Result output**: The function returns the offset values (`y0`, `z0`, `x0`) along with other optional output parameters.
% 7. **Display results**: If the `show` flag is set, the function displays a plot of the original scan data, including the fitted curves and offset points.
% 
% **Notes**
% 
% * The function assumes that the input file or folder contains tab-delimited text files, and uses the `table2array` function to load the data.
% * The `fit` function is used for piecewise linear interpolation, which may not be the most efficient approach for large datasets.
% * The function relies on user-provided initial approximations (`yi`) and dimensionless velocity values (`ratio`), which may require careful tuning for optimal results.
% 
% Overall, this function appears to be designed for analyzing scan data from a CT scanner, with an emphasis on extracting offset values and visualizing the results.
% 

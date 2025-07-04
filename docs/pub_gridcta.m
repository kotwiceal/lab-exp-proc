%% Description
% This is a MATLAB script that appears to be part of a larger workflow for processing and analyzing data from a scanner. Here's a high-level overview of the script:
% 
% 1. The script takes in several input parameters, including:
% 	* `scan`: a matrix representing the scanned data
% 	* `show`: a logical flag indicating whether to display a visual representation of the scan
% 	* `filename` and `extention`: strings specifying the output file name and extension
% 	* `delimiter` (optional): a character string specifying the delimiter used in the output file
% 2. The script performs several operations on the input data:
% 	* It applies a coordinate transformation to transform the scanned data into a more suitable format for further analysis.
% 	* If `show` is `true`, it displays a 3D scatter plot of the original scan, with optional offset and base markers added.
% 	* It writes the transformed data to an output file (if specified) in a matrix format.
% 3. The script also exports the following outputs:
% 	* `scan`: the original scanned data
% 	* `scanoffset`: the transformed coordinates of the scanned data
% 4. If the output file name includes an extension, it saves the `fitobj` structure to a separate file.
% 
% Some notable aspects of the script:
% 
% * It uses the `tiledlayout` function to create a 3D scatter plot with multiple axes.
% * It applies a coordinate transformation using functions like `prepareSurfaceData`, which is not shown in this snippet.
% * It uses MATLAB's built-in functions for plotting, such as `scatter3` and `xlabel`.
% * The script uses optional parameters and default values, making it more flexible and user-friendly.
% 
% To write a similar script from scratch, you would need to:
% 
% 1. Define the input parameters and their expected data types.
% 2. Perform the necessary coordinate transformation using your own functions or MATLAB's built-in functions.
% 3. Create a 3D scatter plot with multiple axes using `tiledlayout` and other plotting functions.
% 4. Write the transformed data to an output file in a matrix format.
% 5. Export the outputs, including any additional structures or values.
% 
% Keep in mind that this script is likely part of a larger workflow, so you may need to consult other scripts and documentation for more information on the specific requirements and assumptions made here.
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
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law and transform unit to mm.
[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...
    offset = {[0, 100], [], [0, 500]}, offsetdim = 3,  ...
    fit = 'poly1', unit = 'mm')
%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law and transform unit to mm with specified basis.
[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...
    offset = {[0, 100], [], [0, 500]}, offsetdim = 3,  ...
    fit = 'poly1', unit = 'mm', refmarker = 'n9')

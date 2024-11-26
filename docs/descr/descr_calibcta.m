%% Description
% This is a MATLAB function named `calibcta` that calibrates hot-wire/film sensors. The function takes several input arguments, including sensor type, wall position, inflow velocity, and node index for poly1 fit. It also has optional arguments to display results and dock the figure.
% 
% Here's a breakdown of the function:
% 
% **Input Arguments**
% 
% * `varargin`: A cell array containing the input values.
% * `kwargs.sensor`: The type of sensor (either 'wire' or 'film').
% * `kwargs.y`: The wall position.
% * `kwargs.u0`: The inflow velocity.
% * `kwargs.index`: The node index for poly1 fit.
% * `kwargs.show`: Whether to display results.
% * `kwargs.docked`: Whether to dock the figure.
% 
% **Function Body**
% 
% The function uses a `switch` statement to determine which sensor type is selected. For each sensor type, it performs the following steps:
% 
% ### Wire Sensor
% 
% * Extracts the probe value, velocity value, and filename from `varargin`.
% * Converts the probe value to a numeric value by removing commas.
% * Writes the probe value and velocity to a matrix file using `writematrix`.
% * Reads the contents of the file and replaces dots with commas.
% * Replaces the delimiter in the file with tabs.
% 
% ### Film Sensor
% 
% * Extracts the wire and film values from `varargin`.
% * Calculates the mean of the wire and film values along the first dimension.
% * Sets default values for `yunit` and `u0isloc` if they are not provided.
% * If `kwargs.y` is empty, sets it to a range of values based on the size of the wire array.
% * If `kwargs.u0` is empty, sets it to the maximum value in the wire array.
% 
% **Processing**
% 
% For the film sensor, the function performs the following steps:
% 
% 1. Shows velocity profiles using `plot`.
% 2. Calculates the derivative of the film values with respect to the y-axis for each node using `prepareCurveData`, `fit`, and `poly1`.
% 3. Performs a piecewise linear fit on the derivatives.
% 4. Displays the calibration results using `plot`.
% 
% **Output**
% 
% The function returns the calibrated film data as an output argument in `varargout`.
% 
% Overall, this function seems to be designed for calibrating hot-wire/film sensors in a specific application, likely related to fluid dynamics or particle tracking.
% 

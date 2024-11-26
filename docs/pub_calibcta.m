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

%% Examples
% This section presents several examples of the usage of calibration
% hot-wire/film CTA
%% Create calibration file for hot-wire CTA, specify voltage and velocity vector correspondily, save to calib_wire.txt
calibcta("1,44266 1,84532 1,9464 2,06614 2,12695 2,20549 2,24979 2,31243 2,39973 2,47017 2,53081 2,58417 2,60222", ...
    [0 2.1 3.6 5.8 7.3 9.6 11.2 13.4 17.3 21.3 25.2 29.1 30.4], ... 
    'docs\src\calibcta\calib_wire.txt')
%% Calibrate hot-film CTA: 
% import vertical velocity profiles measured by hot-wire CTA in the
% vicinity location of hot-film CTA at various inflow veclity in the test
% section;
% import hot-film CTA measurements performed same time

load('docs\src\calibcta\calib_film.mat')

% dins of wire: 1 - samples, 2 - vertical posisiotn, 3 - inflow velocity;
% dins of film: 1 - samples, 2 - sensor channel, 3 - inflow velocity;

calib = calibcta(wire, film, sensor = 'film', y = y, index=3:4)

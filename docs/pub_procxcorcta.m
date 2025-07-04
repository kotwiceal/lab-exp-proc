%% Description
% This MATLAB function, `procxcorcta`, performs cross-spectra analysis on a given dataset. Cross-spectra analysis is a technique used to analyze the relationship between two signals in both time and frequency domains.
% 
% Here's a breakdown of the function:
% 
% **Input Arguments:**
% 
% * `data`: A structure containing spectral estimates for different frequencies.
% * `kwargs`: An optional parameter that allows users to customize the output.
% 
% The input arguments include:
% 	+ `df` (default value 50): The sample spacing.
% 	+ `fgrid` (default value [100:25:900]): The frequency grid points.
% 	+ `phi` (default value 0:5:360): The phase shift values.
% 	+ `varcs`: A character vector specifying the type of cross-spectra analysis to perform:
% 		- 'coh' : Coherence
% 		- 'csd' : Cross-spectra density
% 		- 'csdn' : Normalized cross-spectra density
% 		- 'tf' : Transfer function
% 		- 'csdn1' : Non-normalized transfer function
% 	+ `intspec`: A character vector specifying the type of inter-specification:
% 		- 'sum' : Summation-based
% 		- 'struct': Structured
% 
% **Computations:**
% 
% The function performs the following computations:
% 
% 1. Extracts the cross-spectra density from the input data structure and assigns it to `data.csd`.
% 2. Calculates coherence, transfer function, and normalized cross-spectra density values based on the input frequencies.
% 3. Selects the appropriate cross-spectra value depending on the `varcs` argument.
% 4. If specified, performs inter-specification using either summation-based or structured methods.
% 
% **Phase Rotation:**
% 
% The function performs phase rotation of the selected cross-spectra values:
% 
% 1. Applies a shift to the frequency axis using `shiftdim`.
% 2. Rotates the complex values by adding a phase shift value (`kwargs.phi`) in degrees.
% 3. Normalizes the rotated values by dividing by the magnitude of the corresponding component.
% 
% **Inter-Specification:**
% 
% The function applies inter-specification to the rotated cross-spectra values:
% 
% 1. If `intspec` is set to 'sum', calculates the sum of each component along the time axis using a custom function (`freq2ind`).
% 2. If `intspec` is set to 'struct', uses a predefined structure (`data.intspec`) for inter-specification.
% 
% **Output:**
% 
% The function returns the modified data structure with additional fields containing the transformed cross-spectra values, frequency grid points, sample spacing, and phase shift values.
% 
% In summary, this function provides a flexible framework for performing various types of cross-spectra analysis on a given dataset, allowing users to customize the output according to their specific needs.
% 

%% Examples
% This section presents several examples of the usage of cross-spectra
% analysis
%% Process a coherence, transfer function, phase shifted cross-spectra in frequencies band [100, 300, 500]+[0,15]'
% data = procxcorcta(data, fgrid = [100, 300, 500], df = 15)

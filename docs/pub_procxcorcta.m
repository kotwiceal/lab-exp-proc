%% Description
% This is a MATLAB function named `procxcorcta` that performs various analysis on cross-spectra data. Here's a breakdown of the code:
% 
% **Function signature**
% 
% The function takes two inputs:
% 
% * `data`: a single-cell array of structure, which contains the raw data.
% * `kwargs`: an optional input that allows for customization of the analysis.
% 
% **Keyword arguments**
% 
% The `kwargs` argument is used to customize the analysis. It has four fields:
% 
% * `df`: a double value (default=50) that specifies the frequency band.
% * `fgrid`: a vector of doubles (default=[100:25:900]) that specifies the frequency grid.
% * `phi`: a vector of doubles (default=0:5:360) that specifies the phase values.
% * `varcs`: a character string (required) that selects which cross-spectra component to analyze. The valid options are 'csdn', 'csd', 'tf', and 'csdn1'.
% 
% **Analysis**
% 
% The function performs the following steps:
% 
% 1. Extracts the cross-spectra density from the input data (`data.csd = data.spec{1,3};`).
% 2. Computes the coherence, transfer function, and normalized cross-spectra density using various formulas.
% 3. Applies a phase rotation to the cross-spectra based on the `phi` value.
% 
% **Phase rotation**
% 
% The phase rotation is applied in two steps:
% 
% 1. Shifts the data along the z-axis (second dimension) by one element (`real(shiftdim(temp,-1).*exp(1j*deg2rad(kwargs.phi)),1)`).
% 2. Applies a Fourier transform to the rotated data (`shiftdim` and `cellfun`).
% 
% **Post-processing**
% 
% The function applies additional post-processing to the rotated data:
% 
% 1. Reshapes the output into a cell array with dimensions `[sz(2:3), numel(kwargs.fgrid), sz(4:end)]`.
% 
% **Output**
% 
% The function returns an output structure `data` that contains the following fields:
% 
% * `csd`: the cross-spectra density.
% * `coh`: the coherence.
% * `tf`: the transfer function.
% * `csdn1`: the normalized cross-spectra density (alternative to `csdn`).
% * `rcsd`: the rotated data, which is a cell array with dimensions `[sz(2:3), numel(kwargs.fgrid), sz(4:end)].
% 
% Overall, this function appears to be designed for analyzing cross-spectra data in the context of signal processing or communication systems.
% 

%% Examples
% This section presents several examples of the usage of cross-spectra
% analysis
%% Process a coherence, transfer function, phase shifted cross-spectra in frequencies band [100, 300, 500]+[0,15]'
% data = procxcorcta(data, fgrid = [100, 300, 500], df = 15)

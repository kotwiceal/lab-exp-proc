---
tags:
  - "#MATLAB/topics"
  - "#MATLAB/hot-wire"
---

## Description
---
Present topic explains how to generate scanning grid for hot-wire CTA measurements.
#### Generate scan grid
---
Measurement scan grid generation carried out by [[gridcta]] function.
#### Examples
---

> [!example] Create a 1D scan grid at 3-axis measurement and save into scan_ax1fix_ax2fix_ax3var.txt
> ```octave
> scan = gridcta(0, 0, 0:50:1000, filename = 'scan_ax1fix_ax2fix_ax3var')
> ```
> 


```octave
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

    offset = offset, offsetdim = [2, 3],  ...

    fit = {'poly1', 'poly22'})

%% Create a 2D scan grid at 3-axis measurement with offsetted axis-1 by `linearinterp` law.

[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...

    offset = {[0, 100, 200], [0, 200, 600], []}, offsetdim = 1,  ...

    fit = 'linearinterp')

%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law.

[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...

    offset = {[], [0, 100], [0, 500]}, offsetdim = 3,  ...

    fit = 'poly1')

%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law.

[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...

    offset = {[0, 100], [], [0, 500]}, offsetdim = 3,  ...

    fit = 'poly1')

%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law and transform unit to mm.

[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...

    offset = {[0, 100], [], [0, 500]}, offsetdim = 3,  ...

    fit = 'poly1', unit = 'mm')

%% Create a 2D scan grid at 3-axis measurement with offsetted axis-3 by `poly1` law and transform unit to mm with specified basis.

[scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, ...

    offset = {[0, 100], [], [0, 500]}, offsetdim = 3,  ...

    fit = 'poly1', unit = 'mm', refmarker = 'n9')
```
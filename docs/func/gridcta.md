---
contex:
---
## Syntax
---
```octave
[scan, scanoffset, fitobj] = gridcta(varargin, kwargs)

[scan, scanoffset, fitobj] = gridcta(ax1, kwargs)

[scan, scanoffset, fitobj] = gridcta(ax1, ax2, kwargs)

[scan, scanoffset, fitobj] = gridcta(ax1, ax2, ax3, kwargs)
```
## Description
---
Create pointwise scan grid for hot-wire measurements.
## Examples
---

> [!example]- Create `y` scan grid
> ```octave
> scan = gridcta(0, 0, 0:50:1000)
> ```
> ![[04-Jul-2025 10-57-28.png\|400]]

> [!example]- Create `y-z` scan grid
> ```octave
> scan = gridcta(0, -3000:500:3000, 0:50:1000)
> ```
> ![[04-Jul-2025 12-17-42.png\|400]]

> [!example]- Create `x-y-z` scan grid
> ```octave
> scan = gridcta(0:200:1000, -3000:500:3000, 0:50:1000)
> ```
> ![[04-Jul-2025 12-20-08.png\|400]]

> [!example]- Create `y` scan grid with extented axis
> ```octave
> scan = gridcta(0, 0, 200:100:1000, 0:1)
> ```
> ![[04-Jul-2025 12-24-56.png\|400]]

> [!example]- Create a `y-z` offsetted scan grid  by `poly02` interpolation
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0, -1000:500:1000, 200:100:1000, offset = {0, [-1000, -800, -400, 0, 400, 800, 1000], [-425, -356, -314, -300, -314, -356, -425]}, fit = 'poly02')
> ```
> ![[04-Jul-2025 12-27-05.png\|400]]

> [!example]- Create `x-z` offsetted scan grid by `poly22` interpolation
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = {[0, 250, 500], [-1200, -400, 400, 1200], [-425, -314, -314, -425, -325, -303, -303, -325, 275, 297, 297, 275]}, fit = 'poly22')
> ```
> ![[04-Jul-2025 12-28-57.png\|400]]

> [!example]- Create `x-z` scan grid and change axis order position
> ```octave
> scan = gridcta(0:200:1000, -3000:500:3000, 500, order = [1, 2, 3])
> ```
> ![[04-Jul-2025 12-33-00.png\|400]]

> [!example]- Create `x-z` scan grid with offsetted axis-2 by `poly1` and axis-3 by `poly22` interpolation laws correspondingly
> ```octave
> offset = {{[0, 1000], [0, 5000], []}; {[0, 250, 500], [-1200, -400, 400, 1200], [-425, -314, -314, -425, -325, -303, -303, -325, 275, 297, 297, 275]}};
> 
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = offset, offsetdim = [2, 3], fit = {'poly1', 'poly22'})
> ```
> ![[04-Jul-2025 13-44-15.png\|400]]
> > 

> [!example]- Create `x-z` scan grid with offsetted axis-1 by `linearinterp` interpolation law
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = {[0, 100, 200], [0, 200, 600], []}, offsetdim = 1, fit = 'linearinterp')
> ```
>  ![[04-Jul-2025 13-47-11.png\|400]]

> [!example]- Create `x-z` scan grid with offsetted axis-3 by `poly1` interpolation law
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = {[], [0, 100], [0, 500]}, offsetdim = 3, fit = 'poly1')
> ```
> ![[04-Jul-2025 13-50-27.png\|400]]

> [!example]- Create `x-z` scan grid with offsetted axis-3 by `poly1` interpolation law
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = {[0, 100], [], [0, 500]}, offsetdim = 3, fit = 'poly1')
> ```
> ![[04-Jul-2025 14-24-04.png\|400]]

> [!example]- Create `x-z` scan grid with offsetted axis-3 by `poly1` interpolation law and transform unit to mm
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = {[0, 100], [], [0, 500]}, offsetdim = 3, fit = 'poly1', unit = 'mm')
> ```
> ![[04-Jul-2025 14-26-19.png\|400]]
 
> [!example]- Create `x-z` scan grid with offsetted axis-3 by `poly1` interpolation law and transform unit to mm with specified basis
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = {[0, 100], [], [0, 500]}, offsetdim = 3, fit = 'poly1', unit = 'mm', refmarker = 'n9')
> ```
> ![[04-Jul-2025 14-28-52.png\|400]]

> [!example] Create `x-z` scan grid with offsetted axis-3 by `poly1` interpolation law and transform unit to mm with specified pointwise basis
> ```octave
> [scan, scanoffset, fitobj] = gridcta(0:50:500, -1000:500:1000, 500, offset = {[0, 100], [], [0, 500]}, offsetdim = 3, 
> fit = 'poly1', unit = 'mm', skew = [0, 0; 0, 2e4; 300, 2e4; 300, 0], ort = [113.9, 63.7; 113.9, 112.4; 126.8, 118.9; 126.7, 70.2])
> ```
>![[04-Jul-2025 14-56-34.png\|400]]

## Input Arguments
---
#### Positional Arguments

>[!note]+ ax1, 1D double array
>longitudinal coordinate grid

>[!note]+ ax2, 1D double array
>spanwise coordinate grid

>[!note]+ ax3, 1D double array
>vertical coordinate grid
#### Name-Value Arguments

>[!note] order
>double 1D array contains postition order of each axis

> [!NOTE] orderflip
> logical flip axis order

> [!NOTE] offset
> cell 1D array, axis offsetting points presented in the point/gridwise notation

> [!NOTE] offsetdim
> axis order to apply offset

> [!NOTE] pointwise
> axis order of offsetting vectors to transform from grid to pointwise notation

> [!NOTE] fit
> fit type at applying offset using [build-in methods](https://www.mathworks.com/help/curvefit/fit.html#bto2vuv-1-fitType)
> 
> must be a `poly1`, `poly2`, `plot01`, `poly11`, `poly02`, `poly20` etc.
> 
> default `linearinterp`

> [!NOTE] unit
> transform grid to coordinates 
> must be a `mm`, `count`

> [!NOTE] refmarker
> legacy skew-orthogonal coonrdinate transformation using specified hot-wire CTA base location

> [!NOTE] steps
> 1D array contains steps in 1mm each axis
> 
> type `1D double`
> 
> default `[50, 400, 800]` - longitudinal, spanwise and vertical resolution respectively

> [!NOTE] xfit
> longitudinal fit object like xfit(x,z) function

> [!NOTE] yfit
> vertical fit object like yfit(x,z) function

> [!NOTE] zfit
> spanwise fit object like zfit(x,z) function

> [!NOTE] show
> show figure, 
> 
> type `scalar logical`

> [!NOTE] docked
> docked figure
> 
> type `scalar logical`

> [!NOTE] markersize
> marker size

> [!NOTE] filename
> filename path

> [!NOTE] extention
> text file extention

> [!NOTE] delimiter
> text file delimiter

> [!NOTE] ort
> coordinate system reference points

> [!NOTE] skew
> skew coordinate system reference points
## Output Arguments
---

> [!note] scan
> 2D array containts scanning grid of pointwise notation according to `varargin` values

> [!NOTE] scanoffset
> 2D array containts offsetted scanning grid of pointwise notation according to `varargin` and `offset` values

> [!NOTE] fitobj
> fit objects according specified `offset` `xfit`, `zfit`, `skew`, `ort` parameters


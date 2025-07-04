---
contex:
---
## Syntax
---
```octave
data = loadcta(path, kwargs)
```
## Description
---
Load hot-wire data.
## Examples
---

> [!exapmle] Load hot-wire measurements from specified folder carried out in `labview` with active 3 ADC channel and binary raw data format
> ```octave
> data = loadcta('\data', vendor = 'labview', numch = 3, rawtype = 'bin')
> ```

> [!exapmle] Load hot-wire measurements from specified folder carried out in `LCard` software
> ```octave
> data = loadcta('\data', vendor = 'lcard')
> ```
## Input Arguments
---
#### Positional Arguments

>[!note] path
>data folder path

#### Name-Value Arguments

> [!NOTE] vendor
> specify data import algorithm for vendor software export format
> must be `labview`, `lcard`
> default `labview`

> [!NOTE] subfolders
> `getfilenames` function parameters
> default `false`

> [!NOTE] datadelimiter
> delimiter type of data text file
> default `\t`

> [!NOTE] scandelimiter
> delimiter type of scan text file
> default `\t`

> [!NOTE] rawdelimiter
> delimiter type of raw text file
> default `\t`

> [!NOTE] dataseparator
> separator type of data text file

> [!NOTE] scanseparator
> separator type of scan text file

> [!NOTE] rawseparator
> separator type of raw text file

> [!NOTE] rawextension
> raw text file extension

> [!NOTE] rawtype
> raw data file type 

> [!NOTE] numch
> active ADC channel number at vendor = 'labview'

> [!NOTE] parload
> deprecated

> [!NOTE] calib
> load calibration file and apply to raw data

> [!NOTE] RealChannelsQuantity
> at vendor = 'lcard'

> [!NOTE] fs
> frequency sample

> [!NOTE] DataCalibrScale
> at vendor = 'lcard'

> [!NOTE] DataCalibrZeroK
> at vendor = 'lcard'

> [!NOTE] DataCalibrOffset
> at vendor = 'lcard'

## Output Arguments
---

> [!note] data
> output data stucture

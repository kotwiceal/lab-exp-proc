---
contex:
---
## Syntax
---
```octave
data = prepcta(data, kwargs)
```

## Description
---
Preapare hot-wire data: 
- transform data from pointwire to gridwise notation
- coordinate offset correction
- spectra processing
- spectra correction
## Examples
---

> [!NOTE] Processing hot-wire CTA data
> ```octave
> data = 
> 
>   struct with fields:
> 
>          scan: [2501×10 double]
>           raw: [100000×2×2501 double]
>       voltcal: @(x,ch)voltmap(ch,1)+x.*voltmap(ch,2)
>        velcal: @(vel,tempind)real(coef(1)*((vel.*eccor(tempind)').^2-coef(3)).^coef(2))
>          yfit: [1×1 sfit]
>         label: '240328_134254'
>       reshape: [41 61]
>       permute: []
>            fs: 27000
>     refmarker: 'n8'
> 
> dataprep = prepcta(data, fs = 25e3, spectrumtype = 'psd', freqrange = 'onesided', winfun = 'hanning', winfuncor = true, winlen = 2048, overlap = 512, norm = 'rms', corvibr = true, corvibrind = [1, 2], procamp = 'rms')
> ```
> 

## Input Arguments
---
#### Positional Arguments

>[!note] input
>data structure from [[loadcta]]

#### Name-Value Arguments

> [!NOTE] spectrumtype

> [!NOTE] freqrange
> half, total and total centered spectra

> [!NOTE] winfun
> window function
> must be `uniform`, `hanning`, `hamming`
> default `hanning`

> [!NOTE] winfuncor
> spectra power correction at weighting data by window function
> default `true`

> [!NOTE] winlen
> FFT window length
> defalut `4096`

> [!NOTE] overlap
> FFT window overlay
> defalut `3072`

> [!NOTE] offset
> sliding window offset at performing STFT, `procspec = 'manual'`
> default `0`

> [!NOTE] center
> normalize data, `procspec = 'manual'`
> default `true`

> [!NOTE] fs
> frequency sample Hz

> [!NOTE] norm
> spectra ampliture norm, `rms` means assertion sqrt(sum(spec))=rms(x)

> [!NOTE] corvibr
> suppress vibrations via cross-correlation correction technique
> default `true`

> [!NOTE] corvibrind
> indexes of correcting channel and reference channel
> default `[1,2]`

> [!NOTE] procamp
> amplitude processing method
> must be `rms`, `sum`, `sel`
> default `rms`

> [!NOTE] procspec
> spectra processing method
> must be `spectrogram`, `manual`
> default `spectrogram`

> [!NOTE] reshape
> transform data from pointwire to gridwise notation
> default `[]`

> [!NOTE] permute
> permute axis gridwise notation
> default `[]`

> [!NOTE] unit
> transform scan units
> must be `mm`, `count`
> default `mm`

> [!NOTE] refmarker
> legacy reference marker of skew coordinate system
> must be `none`, `n2`, `n8`, `n9`
> default `none`

> [!NOTE] xfit
> transfrom to leading edge coordinate system
> default `[]`

> [!NOTE] yfit
> fitobj to reverse a correction of vectical scanning component
> default `[]`

> [!NOTE] zfit
> fitobj transfrom to leading edge coordinate system
> default `[]`

> [!NOTE] steps
> single step displacement of step motor in um
> default `[50, 800, 400]`

> [!NOTE] label
> mark data

> [!NOTE] ort
> LE coordinate system reference points
> default `[]`

> [!NOTE] skew
> skew coordinate system reference points
> default `[]`
## Output Arguments
---

> [!note] argout-1

## Description
---
Intermittency processing by statitical approach consitsts a two stage: 
- data preparing: transform raw signal to indicator function then to critiria function
- adjusting statistical paramters: evaluate suppossed statisitcal momenth such as mode, variance etc.
- configure and start non-linear sliding widnow filter
#### Hot-wire signal
---
Considers hot-wire measurements carried out by scaninng `x-z` plane. Spatial grid is $[41\times 61]$, time grid is $10^5$ points. Following structure `data` presents typical data format, where `raw` filed is signal realizatrion, `x`, `z` longitudunal and spanwise coordinate grid respectivelty.  
```octave
data = 

  struct with fields:

    raw: [41×61×100000 double]
      x: [41×61 double]
      z: [41×61 double]

```
Indicator and criteria function is processing by time differentiating using [[prepinterm]] fucntion with followign parameters. 
```octave
data.dudt = prepinterm(data, type = 'dt', diffilt = '4ordgauss', dirdim = 3, pow = 2);
```
Follwing table clarify parameters.

| Parameters              | Description                                                                                                                                                                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `type = 'dt'`           | means 1D filtering passed data along specified dimension by `dirdim` parameter                                                                                                                                                    |
| `diffilt = '4ordgauss'` | means what a kernel is used for data filtering<br>`sobel` - kernel Sobel filter<br>`4ord` - kernel of 4th order finite difference schema<br>`4ordgauss` - kernel of 4th order finite difference schema weighted by Gauss function |
| `dirdim = 3`            | specify a dimenstion of data differentiation                                                                                                                                                                                      |
| `pow = 2`               | power results to specified value                                                                                                                                                                                                  |
Next step is statistical parameters estimation by intecactive mode

```octave
%% define statistical modes constraints
mode1 = [1e-5, 5e-4]; mode2 = [2e-3, 10e-3];
var1 = [1e-08, 3e-7];
%% define statistical bins
binedge = linspace(0,2e-2,300); 

% adjust optimization parameters
x0 = [0.73512, 0.00041316, 0.000173, 0.23057, 0.00080003, 0.00038017];
lb = [1e-2, 0, 0, 0, 0, 0];
ub = [2, 7e-3, 5e-3, 2, 5e-3, 5e-3];

guihist(data.dudt, mask = mask, norm = 'pdf', distname = 'gumbel2', xlim = [binedge(1), binedge(end)], ...
x0 = x0, lb = lb, ub = ub, mode1 = mode1, var1 = var1, mode2 = mode2, legend = true, ...
verbose = true, cdf = true, binedge = binedge, interaction = 'translate', aspect = 'image', clim = [binedge(1), binedge(end)]);
```


| Parameters             | Description                                                |
| ---------------------- | ---------------------------------------------------------- |
| `norm = 'pdf'`         | method of statisitucal distribution normalization          |
| `distname = 'gumbel2'` | analytical distribution for approximation raw distirbution |
| `x0`                   | initial approximation for optimization                     |
| `xmin`                 | lower bounardy constraints                                 |
| `xmax`                 | upper bounardy constraints                                 |
| `mode1`                | 1st statistical mode                                       |
| `mode2`                | 2nd statistical mode                                       |
| `var1`                 | 1st statistical variance                                   |
| `var2`                 | 2nd statistical variance                                   |
| `mean1`                | 1st statistical variance                                   |
| `mean2`                | 2nd statistical variance                                   |
| `interaction`          |                                                            |


```octave
% decompose statistics and apply integral-ratio method
data.gumbel.intrel = procinterm(data.dudt, method = 'integral-ratio', distname = 'gumbel2', mode1 = mode1, mode2 = mode2, var1 = var1, binedge = binedge,
x0 = x0, lb = lb, ub = ub, stride = [1, 1, 1, 1], kernel = [1, 1, 1, nan], padval = false, fitdistinit = false, prefilt = 'none', postfilt = 'none', verbose = true, resources = 'Processes', poolsize = 4);

% decompose statistics and apply cdf-intersection method
data.gumbel.cdfint = procinterm(data.dudt, method = 'cdf-intersection', distname = 'gumbel2', mode1 = mode1, mode2 = mode2, var1 = var1, binedge = binedge, x0 = x0, lb = lb, ub = ub, stride = [1, 1, 1, 1], kernel = [1, 1, 1, nan], padval = false, fitdistinit = false, prefilt = 'none', postfilt = 'none', verbose = true,
resources = 'Processes', poolsize = 4);
```


## PIV signal
---
Considers 2D PIV measurements carried out by scaninng `x-z` plane. Spatial grid is $[41\times 61]$, time grid is $10^5$ points. Following structure `data` presents typical data format, where `raw` filed is signal realizatrion, `x`, `z` longitudunal and spanwise coordinate grid respectivelty.  
```octave
data = 

  struct with fields:

    raw: [41×61×100000 double]
      x: [41×61 double]
      z: [41×61 double]

```
Indicator and criteria function is processing by time differentiating using [[prepinterm]] fucntion with followign parameters. 
```octave
data.dwdl = prepinterm(data, type = 'dt', diffilt = '4ordgauss', pow = 2);
```
Follwing table clarify parameters.


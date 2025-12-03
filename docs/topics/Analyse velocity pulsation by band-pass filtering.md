---
tags:
  - MATLAB/topics
---
#### Description
---
How-wire measurements carried out on `y-z` cross-sections at various `x` positions are considered. Import data by following block:

```octave
% load data
filenames = {
"files/data/cta_f37.6hz_u31.2mps_x230mm_yz_scan_single_rough_h260um_date20251110.mat"
"files/data/cta_f37.6hz_u31.2mps_x235mm_yz_scan_single_rough_h260um_date20251111.mat"
"files/data/cta_f37.6hz_u31.2mps_x240mm_yz_scan_single_rough_h260um_date20251111.mat"
"files/data/cta_f37.6hz_u31.2mps_x245mm_yz_scan_single_rough_h260um_date20251111.mat"
"files/data/cta_f37.6hz_u31.2mps_x250mm_yz_scan_single_rough_h260um_date20251111.mat"
"files/data/cta_f37.7hz_u31.2mps_x255mm_yz_scan_single_rough_h260um_date20251112.mat"
"files/data/cta_f37.7hz_u31.2mps_x260mm_yz_scan_single_rough_h260um_date20251112.mat"
"files/data/cta_f37.7hz_u31.2mps_x265mm_yz_scan_single_rough_h260um_date20251112.mat"
"files/data/cta_f37.8hz_u31.2mps_x270mm_yz_scan_single_rough_h260um_date20251113.mat"
"files/data/cta_f37.8hz_u31.2mps_x275mm_yz_scan_single_rough_h260um_date20251113.mat"
};

data = cellfun(@(f) load(f), filenames, 'UniformOutput', false);
data = cellfun(@(d) prepcta(d.data), data, 'UniformOutput', false);
```

Define frequency band and process RMS amplitude `y-z` fields:
```octave
% process amplitude
freqbands = {[20, 1e3], [4e3, 8e3], [6e3, 10e3], [300, 3e3]}; % frequency bands
amps = cellfun(@(d) cellfun(@(f) d.intspec(d.spec{1,1}, f)./d.vm, freqbands(:), ...
'UniformOutput', false), data(:), 'UniformOutput', false);
amps = [amps{:}]; % unwrap nested cells
```

Show amplitude fields on start and end slices and manually draw polygons to select data:
```octave
% manual draw polygons
[~,~,~,resfunc] = cellplot('contourf',{data{1}.z,data{end}.z},{data{1}.y,data{end}.y}, ...
{amps{4,1},amps{4,end}},axpos=[0,1],facealpha=0.25,axis='equal',ylim=[0,20],...
draw='drawpolygon',rnumber=size(amps,2),...
rcolororder='off',rsnap='off',rlinealign='on',...
ralpha=0.25,rlinewidth=0.25,rposition=[],rfacealpha=0.25,redgealpha=0.25);
```

To get polygon points execute following line:
```octave
% get ROI positions
res = resfunc();
```

To fill by `nan` outside points of amplitude fields execute following block:
```octave
% apply ROI mask to amplutude fields
ampsc = cellfun(@(d,a,p) maskcutdata(p,d.z,d.y,a,dims=[1,2],fill='outnan',shape='trim',ans='on'), ...
repmat(data',size(amps,1),1),amps,[rpos{:}]','UniformOutput',false);
```

Spatial integration in the `y-z` domain of each amplitude fields and plot chord-wise distribution:
```octave
% mean amplitude & show
ampscm = cellfun(@(a) mean(a, [1, 2], 'omitmissing'), ampsc);
x = cellfun(@(d)d.x(1),data);
ll = cellfun(@(l)num2str(l),freqbands,'UniformOutput',false);
cellplot('plot',x,ampscm',axis='square',xlabel='x, mm',ylabel='A_{RMS}/u_e',legend='on',...
ltitle='f, Hz',displayname={{ll}})
```

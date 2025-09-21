---
description: Save all figures in the active window by specified extension
files:
  - "[[saf.m]]"
tags:
  - "#MATLAB/functions"
---
## Syntax
---
```octave
saf(path)
saf(path, kwargs)
```
## Description
---
Save all figures in the active window by specified extension.
## Examples
---
> [!example]+ Store figure in the specified folder
> ```octave
> saf('\plots\')
> ```

> [!example]+ Store figure in the specified folder and adjust figure size `[10, 10]` centimeters width and height respectively
> ```octave
> saf('\plots\', size = [10, 10])
> ```

> [!example]+ Store figure in the specified folder, adjust figure size `[10, 10]` centimeters width and height respectively and insert markdown attachment links
> ```octave
> saf('\plots\', size = [10, 10], md = 'test.md')
> ```
## Input Arguments
---
#### Positional Arguments

>[!note]+ path
>image/figure storing folder
#### Name-Value Arguments

>[!note]+ resolution `default: 300`
>image DPI resolution

>[!note]+ extension `default: '.png'`
>image extension

>[!note]+ md `default: 300`
>markdown file to insert plot links

>[!note]+ units `default: 'centimeters'`
>figure units

>[!note]+ fontsize `default: []`
>figure font size, `[]` means auto font size adjust

>[!note]+ fontunits `default: 'centimeters'`
>font units

>[!note]+ size `default: []`
>figure size, `[]` disables figure position adjusting

>[!note]+ pause `default: 2`
>delay for successful figure appearances changing and saving

>[!note]+ mdsize `default: 400`
>markdown image attachment size

>[!note]+ mdfig `default: true`
>insert `.fig` attachment link

>[!note]+ mdtable `default: true`
>wrap attachment links by table

>[!note]+ mdtabheader `default: false`
>insert empty row for table header

>[!note]+ mdtabalign `default: 'center'`
>lign table cells

>[!note]+ mdtablayout `default: 'flow'`
>arrange attachment link cells


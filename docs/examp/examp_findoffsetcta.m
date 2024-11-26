%% Examples
% This section presents a example of the usage of finding offset by
% measured velocity profiles.
%% Generate a scan grid to measure vertical velocity profiles, import measurements, find offset vertical position
scangridzeros = gridcta([-4050, -3550, -3050], 0:5e3:20e3, flip([-400:50:200, 300:200:2500, 3000, 4000]-300),...
    filename = 'docs\src\findoffsetcta\scan_zeros')

[ax30, ax20, ax10] = findoffsetcta('docs\src\findoffsetcta\data',...
    isovel = 12, ratio = 0.7, y = scangridzeros(:,3))
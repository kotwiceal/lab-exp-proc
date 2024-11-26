%% Examples
% This section presents several examples of the usage of calibration
% hot-wire/film CTA
%% Create calibration file for hot-wire CTA, specify voltage and velocity vector correspondily, save to calib_wire.txt
calibcta("1,44266 1,84532 1,9464 2,06614 2,12695 2,20549 2,24979 2,31243 2,39973 2,47017 2,53081 2,58417 2,60222", ...
    [0 2.1 3.6 5.8 7.3 9.6 11.2 13.4 17.3 21.3 25.2 29.1 30.4], ... 
    'docs\src\calibcta\calib_wire.txt')
%% Calibrate hot-film CTA: 
% import vertical velocity profiles measured by hot-wire CTA in the
% vicinity location of hot-film CTA at various inflow veclity in the test
% section;
% import hot-film CTA measurements performed same time

load('docs\src\calibcta\calib_film.mat')

% dins of wire: 1 - samples, 2 - vertical posisiotn, 3 - inflow velocity;
% dins of film: 1 - samples, 2 - sensor channel, 3 - inflow velocity;

calib = calibcta(wire, film, sensor = 'film', y = y, index=3:4)
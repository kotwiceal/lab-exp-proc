%% test `spectogram` and `manual` implementation results
% signal one-harmonic synthsis
n = 1024*10;
T = 1;
t = linspace(0, T, n);
fs = 1/(t(2)-t(1));

f1 = 1000;

x = sin(f1/(pi/2)*t)*2+5;

% show signal
clf; tiledlayout('flow');
nexttile; hold on; grid on; box on; axis square; 
plot(t,x,'.-');
xlim([0, 1*T])
xlabel('t'); ylabel('x');
%% test procspec, twosided, psd, uniform
label = "procspec, twosided, psd, uniform";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='centered',spectrumtype='psd',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspec, twosided, power, uniform
label = "procspec, twosided, power, uniform";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='centered',spectrumtype='power',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspec, onesided, psd, uniform
label = "procspec, onesided, psd, uniform";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='onesided',spectrumtype='psd',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspec, onesided, power, uniform
label = "procspec, onesided, power, uniform";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='onesided',spectrumtype='power',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspec, twosided, psd, hanning
label = "procspec, twosided, psd, hanning";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='centered',spectrumtype='psd',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspec, twosided, power, hanning
label = "procspec, twosided, power, hanning";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='centered',spectrumtype='power',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspec, onesided, psd, hanning
label = "procspec, onesided, psd, hanning";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='onesided',spectrumtype='psd',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspec, onesided, power, hanning
label = "procspec, onesided, power, hanning";
[spec, f] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='onesided',spectrumtype='power',...
    winfuncor=true);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, twosided, psd, uniform
label = "procspecn, twosided, psd, uniform";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='double',type='psd',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, twosided, power, uniform
label = "procspecn, twosided, power, uniform";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='double',type='power',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, onesided, psd, uniform
label = "procspecn, onesided, psd, uniform";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='single',type='psd',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, onesided, power, uniform
label = "procspecn, onesided, power, uniform";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='single',type='power',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, twosided, psd, hanning
label = "procspecn, twosided, psd, hanning";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='double',type='psd',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, twosided, power, hanning
label = "procspecn, twosided, power, hanning";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='double',type='power',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, onesided, psd, hanning
label = "procspecn, onesided, psd, hanning";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='single',type='psd',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)*df), rms(x(:)), sqrt(sum(spec)*df)./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% test procspecn, onesided, power, hanning
label = "procspecn, onesided, power, hanning";
[spec, f] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='single',type='power',center=false);
df = f(2) - f(1);
% Parcevall identity
[sqrt(sum(spec)), rms(x(:)), sqrt(sum(spec))./rms(x(:))]
plotspec(f,spec,xscale='linear',title=label)
%% comare procspec and procspecn, twosided, psd, uniform
label = "twosided, psd, uniform";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='centered',spectrumtype='psd',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='double',type='psd',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% comare procspec and procspecn, twosided, power, uniform
label = "twosided, power, uniform";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='centered',spectrumtype='power',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='double',type='power',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% comare procspec and procspecn, onesided, psd, uniform
label = "onesided, psd, uniform";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='onesided',spectrumtype='psd',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='single',type='psd',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% comare procspec and procspecn, onesided, power, uniform
label = "onesided, power, uniform";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='uniform',norm='rms',fs=fs,freqrange='onesided',spectrumtype='power',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='uniform',norm=true,fs=fs,side='single',type='power',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% comare procspec and procspecn, twosided, psd, hanning
label = "twosided, psd, hanning";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='centered',spectrumtype='psd',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='double',type='psd',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% comare procspec and procspecn, twosided, power, hanning
label = "twosided, power, hanning";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='centered',spectrumtype='power',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='double',type='power',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% comare procspec and procspecn, onesided, psd, hanning
label = "onesided, psd, hanning";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='onesided',spectrumtype='psd',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='single',type='psd',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% comare procspec and procspecn, onesided, power, hanning
label = "onesided, power, hanning";
[spec1, f1] = procspec(x(:),winlen=1024,overlap=512,ans='double',...
    winfun='hanning',norm='rms',fs=fs,freqrange='onesided',spectrumtype='power',...
    winfuncor=true);

[spec2, f2] = procspecn(x(:),winlen=1024,overlap=512, ...
    winfun='hanning',norm=true,fs=fs,side='single',type='power',center=false);

plotcompspec(f1,spec1,f2,spec2,xscale='linear',title=label)
%% define functions
function plotspec(f,spec,kwargs)
    arguments
        f double {mustBeVector}
        spec double {mustBeVector}
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.title (1,:) char = []
    end
    clf; tiledlayout('flow');
    nexttile; hold on; grid on; box on; axis square;
    set(gca, xscale=kwargs.xscale, yscale=kwargs.yscale)
    plot(f, spec, '.-');
    xlabel('f'); ylabel('spectra');
    if ~isempty(kwargs.title); title(kwargs.title,FontWeight='normal'); end
end

function plotcompspec(f1,spec1,f2,spec2,kwargs)
    arguments
        f1 double {mustBeVector}
        spec1 double {mustBeVector}
        f2 double {mustBeVector}
        spec2 double {mustBeVector}
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.title (1,:) char = []
    end
    clf; tiledlayout('flow');
    nexttile; hold on; grid on; box on; axis square;
    set(gca, xscale=kwargs.xscale, yscale=kwargs.yscale)
    plot(f1, spec1, '.-');
    plot(f2, spec2, '.-');
    legend({'procspec', 'procspecn'})
    xlabel('f'); ylabel('spectra');
    if ~isempty(kwargs.title); title(kwargs.title,FontWeight='normal'); end
end
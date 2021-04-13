close all force;
clear;
clc;

%% Filter Specifications

f = 100;       %Hz
width = 20;    %log
depth = -20;   %dB

wn = f*2*pi; %rad/s

a = width/2;
b = db2mag(depth);

qsi=b*(1+a^2)/(2*a);       % Necessary damping to satisfy specs


%% Transfer Function

s=tf('s');

Fw1 = (wn*a)/(s + wn*a);    % Pole before wn
Fw2 = (wn/a)/(s + wn/a);    % Pole after wn
Fwn = (s^2 + 2*qsi*wn*s + wn^2)/(wn^2);

F = Fw1*Fwn*Fw2;

%% Bode

bodeopts = bodeoptions;

bodeopts.Grid = 'on'                % 'off'        / 'on'

bodeopts.FreqUnits = 'Hz';          % 'rad/second' / 'Hz' 

bodeopts.MagUnits = 'dB';           % 'dB'         / 'abs'
bodeopts.PhaseUnits = 'deg';        % 'deg'        / 'rad'

bodeopts.FreqScale = 'log';         % 'log'        / 'linear' 
bodeopts.MagScale = 'linear';       % 'linear'     / 'log'  


bode(F,bodeopts)

%% Frequency Response

w = wn;

H = mag2db(freqresp(F,w))       % Magnitude in frequency w

%% Digital

Fs = 20e3;
Ts = 1/Fs;

% ZOH
F_zoh = c2d(F, Ts, 'zoh');

% Tustin
F_bil = c2d(F, Ts, 'tustin');

% Tustin - Prewarp
filtopts = c2dOptions('Method', 'tustin', 'PrewarpFrequency', wn); 
F_pwp = c2d(F, Ts, filtopts);

% Matched
F_mtc = c2d(F, Ts, 'matched');

figure();
hold on;
bode(F, bodeopts);
% bode(F_zoh);
% bode(F_bil);
% bode(F_pwp);
bode(F_mtc);

%% Coeficients of 1 + z^-1 + + z^-2 + ...

Fd = F_mtc;         % Chosen method for c2d

[num,den]= tfdata(Fd);

num = cell2mat(num);
den = cell2mat(den);

num = num/(num(1));
den = den/(den(1));

Fd = tf(num,den,Ts,'Variable','z^-1');

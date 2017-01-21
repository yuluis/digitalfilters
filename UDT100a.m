% 100 MHz equalization filter for use with QDR
% Assumes UDT -> QDR 
% Read in 5 to 100 MHz smoothed response datafile
% 3/20/2014: Original, compensates for reponse that already has sinc
% correction digital filter in QDR
% 3/21/2014: Modified to compensate for all UDT 100 MHz tilt
% 4/9/2014: digital filter has too much ripple, reduce bandwidth
M = dlmread('UDT_QDR_100m2fer_v7.16_attn24_filterOFF_Zoom.CSV', ',', 3, 0);

% Compute necessary filter response
fs =  212500000;
fhs = fs/2;
x = M(:,1);
xn = x/fhs;
y = M(:,2);
ym = max(y);
yn = ym-y;
ym = max(yn);
yn = yn - ym;

% Design filter
F = vertcat(0,xn, 1);
An = 10.^(yn/20);
As = 0.5;
Af = 0.95;
A = vertcat(As, An, Af);
R = 0.005; % ripple
ds = size (F,1);
W = ones(ds,1);
W(1) = 0.001; % low weighting in arbmag design
%W(2) = 0.001; % low weighting in arbmag design

Ws = size(W,1);
W(Ws) = 0.001;

d = fdesign.arbmag('F,A,R', F,A,R);
Hd = design(d,'equiripple','weights',W,'SystemObject',true);
% Plot and analyze filter
h = fvtool(Hd,'MagnitudeDisplay', 'Magnitude (dB)', 'Fs',fs,...fv
    'Color','White');

% export coefficients
c= Hd.Numerator;
ct = transpose(c);
% c = c * 10^(3/20) scale 10^(3/20) for 3 dB increase
save('UDT100a.txt', 'c', '-ascii', '-double');
dlmwrite('UDT50a.txt', c, 'precision', 20);
save('UDT100at.txt', 'ct', '-ascii', '-double');
dlmwrite('UDT100at2.txt', ct, 'precision', 20);

% show coefficient area
sum(abs(c))

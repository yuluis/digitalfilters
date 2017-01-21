% 100 MHz equalization filter for use with QDR
% Assumes UDT -> QDR 
% Read in 5 to 100 MHz smoothed response datafile
% 3/20/2014: Original, compensates for reponse that already has sinc
% correction digital filter in QDR
% 3/21/2014: Modified to compensate for all UDT 100 MHz tilt
% 3/25/2014: attempt to reduce ripple and add a slight uptilt at 100 MHz
% 4/9/2014: compensate with Rev2 analog filter
% 4/11/2014: modify for QDR 50MHz eq when used with QDR
% 4/12/2014: modify for HDT 50 MHz eq when used with QDR

M = dlmread('HDT_50M-1FER_trace_data_45.CSV', ',', 3, 0);

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
As = 0.8;
Af = 0.4;
A = vertcat(As, An, Af);
%R = 0.001; % ripple 50-tap filter; .1 dB ripple
R = 0.0008; % 40-tap 0.1 dB ripple
ds = size (F,1);
W = 0.1* ones(ds,1);
W(200:300) = 0.2;
%W(377:403) = 0.05; % reduce 45 to 50 MHz constraint
W(1) = 0.00000000001; % low weighting in arbmag design
%W(2) = 0.001; % low weighting in arbmag design

Ws = size(W,1);
W(Ws) = 0.00000000001;

d = fdesign.arbmag('F,A,R', F,A,R);
Hd = design(d,'equiripple','weights',W,'SystemObject',true);
% Plot and analyze filter
h = fvtool(Hd,'MagnitudeDisplay', 'Magnitude (dB)', 'Fs',fs,...fv
    'Color','White');

% export coefficients
c= Hd.Numerator;
ct = transpose(c);
% c = c * 10^(3/20) scale 10^(3/20) for 3 dB increase
%save('FDT50.txt', 'c', '-ascii', '-double');
dlmwrite('HDT50.txt', c, 'precision', 20);
%save('FDT50t.txt', 'ct', '-ascii', '-double');
%dlmwrite('FDT50t.txt', ct, 'precision', 20);

% show coefficient area
sum(abs(c))

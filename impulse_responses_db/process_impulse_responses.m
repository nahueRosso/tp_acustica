%Using Scale Modelling to Assess the Prehistoric Acoustics of Stonehenge
%Trevor J. Cox, Bruno M. Fazenda, Susan E. Greaney
%Journal of Archaeological Science

%code to show how to apply gains to published octave-band impulse responses
%because wav files have been normalised to give an abs(maximum value) of 1
%gains are in gains.txt file for each measurement

%Loads in a set of octave band impulse responses for one source-receiver
%pair and applyied gains so the relative level between different
%measurements are be correct.

%The impulse responses are in h(:,ii), where ii is the octave band
%with frequencies in freq()
%LpE(ii) is the level for the measurement

%The final sample values are not in Pascals.
%The level from a free-field measurement of the source is given 
%LpE10(ii) is the level averaged over a horizontal polar response at 10m
%(full-scale equivalent) for the source in the free-field. This allows a
%calculation of G.

clear all
close all
clc

freq = [125,250,500,1000,2000,4000];
nf = length(freq);

%Calibration data from on-axis free field measurement of the source
datapathG = 'calibration\quad_source';
filenamegains = [datapathG '\gains.txt'];
fid = fopen(filenamegains,'rt');
for ii = 1:nf
    fgets(fid);
    A = str2num(fgets(fid));
    amp_gain = A(2);                %gain of UFZ+measuring amp same for each freq
    peak_mag(ii) = A(3);   %peak gain of impulse response (used for normalisation before writing to wav)
end
fclose(fid);
%non_omni_compensation is calculated from directivity measurement for source
%Figure 4 in the paper. This %compensates for non-omnidirectional response
%in horizontal plane
non_omni_compensation = [1.5, 2.7, -2.1, -2.4, -4, -8.2]';

%load in calibration source on-axis free field impulse response
for ii=1:nf
    filename_oct = [datapathG sprintf('\\IR_%d.wav',freq(ii))];
    [h_oct,fs] = audioread(filename_oct);
    h_oct = h_oct*peak_mag(ii);             %restore peak gain of impulse response
    h_oct = h_oct / 10^(amp_gain/20);       %set to peak if  UFZ+measuring amp had zero dB gain
    LpE12 = 10*log10(sum(h_oct.^2));        %the free field measurement was at 1m (model scale)
    LpE10(ii) = LpE12 + 20*log10(12/10);    %correction because calibration was done at 12m (full-scale equivalent)
    LpE10(ii) = LpE10(ii) + non_omni_compensation(ii);      %correction for source not being omni
end

%folder that contains the impulse response and gains file for one 
%source-receiver pair
datapath = '2200BC model\sc-m22';
for ii=1:nf
    filename = [datapath sprintf('\\IR_%d.wav',freq(ii))];
    [h(:,ii),fs] = audioread(filename);
end
filenamegains = [datapath '\\gains.txt'];
fid = fopen(filenamegains,'rt');
for ii = 1:nf
    fgets(fid);
    A = str2num(fgets(fid));
    amp_gain = A(2);            %gain of UFZ+measuring amp same for each freq
    peak_mag(ii) = A(3);        %peak gain of impulse response (used for normalisation before writing to wav)
end
    
for ii=1:nf
    h(:,ii) = h(:,ii)*peak_mag(ii);    %restore peak gain of impulse response
    h(:,ii) = h(:,ii) / 10^(amp_gain/20);       %set to peak if  UFZ+measuring amp had zero dB gain
    LpE(ii) = 10*log10(sum(h(:,ii).^2));
end
fclose(fid);

%mid-frequency G (500 Hz and 1000 Hz octave band)
Gmid = mean(LpE(3:4)-LpE10(3:4));

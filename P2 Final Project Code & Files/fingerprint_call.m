function [fingerprint] = fingerprint_call(bird_name, wav_file)
%% Creation of Fingerprints of Bird Calls
% Written by: Sarah Fraser
% ID: 20458408
% CS 489: Computational Audio
% Includes: 
% - figure of audio audio signal
% - figure of DFT
% - figure of Smooth DFT and Peaks
% - Fingerprint vector of given call

% For Testing Usage Only
%bird_name = 'Mocking Bird'
%wav_file = 'mocking.wav'

% Global Variables
info = audioinfo(wav_file);
fs = info.SampleRate
N = info.TotalSamples

% Read in audio signal
audio_signal = audioread(wav_file);
x = audio_signal(1:N);

% Computed Globals
dt=1/fs;
df=fs/N;
T=N*dt;
time=transpose((1:N)/fs);
fidx=transpose(-floor(N/2):floor((N-1)/2));
freq=fidx*fs/N;

% Figure of Audio Signal
%figure1 = figure;
%plot(time,x,'-b');
%xlabel('Time (s)');
%ylabel('x(t)')
%title(sprintf('%s Call', bird_name));

%saveas(figure1, sprintf('%s Call Wave.jpg', bird_name));

% Compute DFT
X=fft(x);

% Figure of DFT
%figure2 = figure;
%plot(freq,fftshift(abs(X)));
%title(sprintf('DFT for %s Call', bird_name));
%xlabel('Frequency (Hz)');
%ylabel('abs(X(f_k))');

%saveas(figure2, sprintf('%s Call DFT.jpg', bird_name));

%% Time to Smooth

% Smooth Globals
f_range=5; % Range in Hz
n_repeats=5;  %n_repeats=5;
W=abs(freq)<f_range/2; 
W=W/sum(W);

% Frequency Weighting for DFT
while n_repeats>1,
    W=cconv(W,fftshift(W),N);
    %plot(freq,W,'.');
    n_repeats=n_repeats-1;
end

% Smooth the Magnitude Only (not the phase)
X_smooth_magnitude=cconv(abs(X),fftshift(W),N);
X_smooth=X_smooth_magnitude.*exp(j*angle(X));

% Plot the Smoothed DFT vs Normal DFT
%figure;
%plot(freq,fftshift(abs(X)),'g-',freq,fftshift(abs(X_smooth)),'k-');
%hold on;
%legend('Input DFT','Smoothed DFT');

%% Find Peaks of Smoothed DFT
idx=fidx( freq>0 & freq<110000); 
ii=transpose(1:numel(idx));
[pks,locs]=findpeaks(abs(X_smooth(idx)),'MINPEAKDISTANCE',round(f_range*2/df),'MINPEAKHEIGHT',5);
%figure3 = figure;
%plot(ii*df,abs(X(idx)),'g-',ii*df,abs(X_smooth(idx)),'k-',locs*df,pks,'r*');
%xlabel('Frequency (Hz)'); 
%ylabel('abs(X)');
%title(sprintf('Smoothed DFT & Peaks of %s Call', bird_name))

%saveas(figure3, sprintf('%s Call Smoothed DFT & Peaks.jpg', bird_name));

%% Create Fingerprint from Peaks

% Range of 100 Hz per Fingerprint Bin
range_start = 0;
range_end = 15000;

% Compute Number of Bins
num_hz_bins = (range_end - range_start)/100;
num_hz_bins;
bins = zeros(1,num_hz_bins);

% Adjust locs to reflect df
new_locs = locs*df;

% For each Hz bin, find the highest peak
% from smoothed DFT and save
lower_hz = 0;
higher_hz = 100;
for i=1:length(bins)
	peaks_in_range = pks(find(new_locs>=lower_hz&new_locs<=higher_hz));
	if length(peaks_in_range) ~= 0
		bins(i) = max(peaks_in_range);
	end
	lower_hz = lower_hz + 100;
	higher_hz = higher_hz + 100;
end

%save(sprintf('Fingerprint %s Call.mat',bird_name),'bins');

fingerprint = bins





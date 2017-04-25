function varargout = chirp_o_matcher(varargin)
% CHIRP_O_MATCHER MATLAB code for chirp_o_matcher.fig
%      CHIRP_O_MATCHER, by itself, creates a new CHIRP_O_MATCHER or raises the existing
%      singleton*.
%
%      H = CHIRP_O_MATCHER returns the handle to a new CHIRP_O_MATCHER or the handle to
%      the existing singleton*.
%
%      CHIRP_O_MATCHER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHIRP_O_MATCHER.M with the given input arguments.
%
%      CHIRP_O_MATCHER('Property','Value',...) creates a new CHIRP_O_MATCHER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chirp_o_matcher_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chirp_o_matcher_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDEs Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chirp_o_matcher

% Last Modified by GUIDE v2.5 04-Apr-2016 18:23:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chirp_o_matcher_OpeningFcn, ...
                   'gui_OutputFcn',  @chirp_o_matcher_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before chirp_o_matcher is made visible.
function chirp_o_matcher_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chirp_o_matcher (see VARARGIN)

% Choose default command line output for chirp_o_matcher
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chirp_o_matcher wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = chirp_o_matcher_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = uigetfile('*.wav','Select the Bird Call Audio File');
set(handles.edit1, 'String', sprintf('%s', filename));
handles.filename=filename;
guidata(hObject,handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

filename = get(hObject,'String');
handles.filename=filename;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bird_name = 'Unknown Bird';
filename = handles.filename;
display(bird_name);
prints = fingerprint_call(bird_name,filename);
display(prints);
bird_match = match_fingerprints(prints);
display(bird_match);

set(handles.edit2, 'String', bird_match);
axes(handles.axes1);
bird_picture = sprintf('%s.jpg', bird_match{1});
matlabImage = imread(bird_picture);
image(matlabImage)
axis off
axis image

info = audioinfo(filename);
fs = info.SampleRate;
N = info.TotalSamples;

audio_signal = audioread(filename);
x = audio_signal(1:N);

dt=1/fs;
df=fs/N;
T=N*dt;
time=transpose((1:N)/fs);
fidx=transpose(-floor(N/2):floor((N-1)/2));
freq=fidx*fs/N;

X=fft(x);

f_range=5; % Range in Hz
n_repeats=5;  %n_repeats=5;
W=abs(freq)<f_range/2; 
W=W/sum(W);

while n_repeats>1,
    W=cconv(W,fftshift(W),N);
    n_repeats=n_repeats-1;
end

X_smooth_magnitude=cconv(abs(X),fftshift(W),N);
X_smooth=X_smooth_magnitude.*exp(j*angle(X));

idx=fidx( freq>0 & freq<110000); 
ii=transpose(1:numel(idx));
[pks,locs]=findpeaks(abs(X_smooth(idx)),'MINPEAKDISTANCE',round(f_range*2/df),'MINPEAKHEIGHT',5);

axes(handles.axes2);

plot(ii*df,abs(X(idx)),'g-',ii*df,abs(X_smooth(idx)),'k-',locs*df,pks,'r*');
xlabel('Frequency (Hz)'); 
ylabel('abs(X)');
title(sprintf('Smoothed DFT & Peaks of %s Call',bird_match{1}))

guidata(hObject, handles);

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = handles.filename;
[y,Fs] = audioread(filename);
sound(y,Fs);


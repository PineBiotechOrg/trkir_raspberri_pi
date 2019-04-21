function varargout = GUITest(varargin)
% GUITEST MATLAB code for GUITest.fig
%      GUITEST, by itself, creates a new GUITEST or raises the existing
%      singleton*.
%
%      H = GUITEST returns the handle to a new GUITEST or the handle to
%      the existing singleton*.
%
%      GUITEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUITEST.M with the given input arguments.
%
%      GUITEST('Property','Value',...) creates a new GUITEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUITest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUITest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUITest

% Last Modified by GUIDE v2.5 13-Oct-2015 16:24:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUITest_OpeningFcn, ...
                   'gui_OutputFcn',  @GUITest_OutputFcn, ...
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


% --- Executes just before GUITest is made visible.
function GUITest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUITest (see VARARGIN)

% Choose default command line output for GUITest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%fig = imread('flirLogo.png');
%axes(handles.axes2);
%imshow(fig);



%hasIPT = license('test', 'image_toolbox');
%if ~hasIPT
	% User does not have the toolbox installed.
%	message = sprintf('Sorry, but you do not seem to have the Matlab Image
%	Processing Toolbox.\nYou will not be able to run the Edge or Segmentation filter.\nContinue anyway?');
%	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
%	if strcmpi(reply, 'No')
		% User said No, so exit.
%		return;
%	end
%end

% UIWAIT makes GUITest wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUITest_OutputFcn(hObject, eventdata, handles) 
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

%AddAssembly Flir.Atlas.Live.dll
atPath = getenv('FLIR_Atlas_MATLAB');
atLive = strcat(atPath,'Flir.Atlas.Live.dll');
asmInfo = NET.addAssembly(atLive);
%init camera discovery
test = Flir.Atlas.Live.Discovery.Discovery;
% search for cameras for 5 seconds
disc = test.Start(5);
% put the result in a list box
for i =0:disc.Count-1 
 s1 = strcat(char(disc.Item(i).Name),'::');
 s2 = strcat(s1,char(disc.Item(i).SelectedStreamingFormat));
 str{i+1} =  s2;   
end   
set(handles.listbox1,'string',str);

handles.disc = disc;
guidata(hObject,handles)

 
 


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
index_selected = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonConnect.
function pushbuttonConnect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for index=0
disc = handles.disc;
% check if it is FlirFileFormat or mpeg streaming
if(strcmp(char(disc.Item(index_selected-1).SelectedStreamingFormat),'FlirFileFormat'))
    %It is FlirFileFormat init a ThermalCamera
    ImStream = Flir.Atlas.Live.Device.ThermalCamera(true);    
    ImStream.Connect(disc.Item(index_selected-1));
    %save the stream
    handles.ImStream = ImStream;
    handles.stop = 1;
    
    editString = datestr(now, 'mm_dd_yy_HH_MM_AM');
    set(handles.edit2,'string', editString);
    
    guidata(hObject,handles)
    %set the Iron palette
    pal = ImStream.ThermalImage.PaletteManager;
    ImStream.ThermalImage.Palette = pal.Iron; 
    pause(1);
    while handles.stop
      %get the colorized image   
      img = ImStream.ThermalImage.ImageArray;
      %convert to Matlab type
      X = uint8(img);
      %imwrite(mat2gray(X), 'D:\17.06\test.jpg');
      axes(handles.axes1);
      imshow(X);
      drawnow
      handles = guidata(hObject);
     
      %Read temp from spot 
  %    Temperature = spot.Value.Value
    end
else
    %mpeg stream
   ImStream = Flir.Atlas.Live.Device.VideoOverlayCamera(true);
   %connect
    ImStream.Connect(disc.Item(index_selected-1));
    handles.ImStream = ImStream;
    handles.stop = 1;
    guidata(hObject,handles)
    pause(1);
    while handles.stop
        % get the Image
        img = ImStream.VisualImage.ImageArray;
        X = uint8(img);  
        axes(handles.axes1);
        imshow(X,[]);
        drawnow
        handles = guidata(hObject);
    end    
end
ImStream = handles.ImStream;
ImStream.Disconnect();
ImStream.Dispose();


% --- Executes on button press in pushbuttonLeftInfection.
function pushbuttonLeftInfection_Callback(hObject, eventdata, handles)
fid = fopen(sprintf('%s/left_infection.txt', handles.dirname),'w');
editString = datestr(now, 'mm_dd_yy_HH_MM_AM');
editString = strrep(editString, ' ', '');
fprintf(fid, '%s', editString); 
fclose(fid);
system(sprintf('ssh root@159.89.232.110 python3 /root/Novosad/mouses/create_avg_day.py %s 0 &', handles.dirname))
guidata(hObject, handles);

% --- Executes on button press in pushbuttonRightInfection.
function pushbuttonRightInfection_Callback(hObject, eventdata, handles)
fid = fopen(sprintf('%s/right_infection.txt', handles.dirname),'w');
editString = datestr(now, 'mm_dd_yy_HH_MM_AM');
editString = strrep(editString, ' ', '');
fprintf(fid, '%s', editString); 
fclose(fid);
%system(sprintf('ssh root@159.89.232.110 python3 /root/Novosad/mouses/create_avg_day.py %s 1 &', handles.dirname))
guidata(hObject, handles);

% --- Executes on button press in pushbuttonStartRec.
function pushbuttonStartRec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStartRec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stop_rec = 1;
editString_start = datestr(now, 'mm_dd_yy_HH_MM_AM');
editString_start = strrep(editString_start, ' ', '');
set(handles.edit2, 'string', editString_start);
guidata(hObject,handles);
ImStream = handles.ImStream;

fprintf('DIR CREATED %s', sprintf('%s_', editString_start));
if exist(editString_start, 'dir')
%    editString_start = editString_start + '_2';
    rmdir(editString_start, 's');
end
mkdir(editString_start);
%mkdir(editString, 'JPEG');
%mkdir(editString, 'Stats');
n_frames = 60000;

upload_url = 'http://127.0.0.1:5001/upload';
camera_url = 'http://127.0.0.1:5000/check_camera';

opts = weboptions('MediaType','application/json');
opts.Timeout = 5;%n_frames / 10;

while handles.stop_rec
 %   if ~is_first
 %       to_json = struct('dirname', editString_start, 'subdirname', editString);
 %       response = webwrite(upload_url, to_json, opts);
 %   end
    editString = datestr(now, 'mm_dd_yy_HH_MM_AM');
    editString = strrep(editString, ' ', '');
%    if exist(editString_start + '/' + editString, 'dir')
%    rmdir(editString, 's');
%    end
    mkdir(sprintf('%s/%s', editString_start, editString));
    mkdir(sprintf('%s/%s/%s', editString_start, editString, 'JPEG'));
    mkdir(sprintf('%s/%s/%s', editString_start, editString, 'Stats'));

    fid = fopen(sprintf('%s/%s/Stats/thermal.txt', editString_start, editString),'at');

    i = 0;
    while i < n_frames && handles.stop_rec
   %     if i ~= 0  && mod(i, int16(0.01 * n_frames)) == 0
   %         to_json = struct('dirname', editString_start, 'subdirname', editString);
   %         response = webwrite(camera_url, to_json, opts);
   %     end
        pause(0.1);
        %get the colorized image   
        fprintf(fid, '%s\t%s\t%d\t%d\t%d\n', editString, char(ImStream.ThermalImage.DateTime.ToString()), i, ImStream.ThermalImage.Statistics.Min.Value, ImStream.ThermalImage.Statistics.Max.Value);
        fid_temp = fopen('./images/temp.txt','w');
        fprintf(fid_temp, '%d', ImStream.ThermalImage.Statistics.Max.Value + 470);
        fclose(fid_temp);
        
        img = ImStream.ThermalImage.ImageProcessing.GetPixelsArray;
        img = double(img);
        img=img-min(img(:)); % shift data such that the smallest element of A is 0
        img=img/max(img(:)); % normalize the shifted data to 1 
        imwrite(img,  sprintf('%s/%s/JPEG/%d.jpg', editString_start, editString, i));
        imwrite(img,  './images/2.jpg');
        i = i + 1;

        handles = guidata(hObject);
  
    end
    fclose(fid);
 %   is_first = false;
end
fid = fopen(sprintf('%s/done.txt', editString_start),'w');
fclose(fid);
handles = guidata(hObject);



%start recording
%ImStream.Recorder.Start(edit);
% --- Executes on button press in pushbuttonStopRec.
function pushbuttonStopRec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStopRec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stop_rec = 0;
guidata(hObject,handles);
%ImStream = handles.ImStream;
%stop recording
%ImStream.Recorder.Stop;


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.edit2 = get(hObject,'string');
guidata(hObject,handles);

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



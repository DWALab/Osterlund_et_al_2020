
function varargout = Compress_INO_Data_GUI_V2(varargin)
% COMPRESS_INO_DATA_GUI_V1 M-file for Compress_INO_Data_GUI_V1.fig
%      COMPRESS_INO_DATA_GUI_V1, by itself, creates a new COMPRESS_INO_DATA_GUI_V1 or raises the existing
%      singleton*.
%
%      H = COMPRESS_INO_DATA_GUI_V1 returns the handle to a new COMPRESS_INO_DATA_GUI_V1 or the handle to
%      the existing singleton*.
%
%      COMPRESS_INO_DATA_GUI_V1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPRESS_INO_DATA_GUI_V1.M with the given input arguments.
%
%      COMPRESS_INO_DATA_GUI_V1('Property','Value',...) creates a new COMPRESS_INO_DATA_GUI_V1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Compress_INO_Data_GUI_V1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Compress_INO_Data_GUI_V1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
global InputDataFolder OutputDataFolder;
% Setting the path to the codes in MATLAB
CodesLocation = pwd;
addpath(CodesLocation);

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Compress_INO_Data_GUI_V1_OpeningFcn, ...
                   'gui_OutputFcn',  @Compress_INO_Data_GUI_V1_OutputFcn, ...
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


% --- Executes just before Compress_INO_Data_GUI_V1 is made visible.
function Compress_INO_Data_GUI_V1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Compress_INO_Data_GUI_V1 (see VARARGIN)

% Choose default command line output for Compress_INO_Data_GUI_V1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.text2, 'String', '');
% UIWAIT makes Compress_INO_Data_GUI_V1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Compress_INO_Data_GUI_V1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% Read all the tif files from their respective folders
global InputDataFolder OutputDataFolder;
InputDataFolder = uigetdir('C:\','Select the Data Folder'); 
OutputDataFolder = InputDataFolder


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press to select output data folder.
function pushbutton2_Callback(hObject, eventdata, handles)
global InputDataFolder OutputDataFolder;
OutputDataFolder = uigetdir(InputDataFolder,'Select the Data Folder'); 

% --- Executes on button press to compress data.
function pushbutton4_Callback(hObject, eventdata, handles)
global InputDataFolder OutputDataFolder;
%Check to mak sure input and output folders are not the same
    if(strcmp(InputDataFolder, OutputDataFolder))
        f=errordlg('Input File and Output File are the same.');
        return
    end

%Check to see if user would like to delete original files

%f = warndlg( {strcat('Input Folder = ', InputDataFolder); strcat('Output Folder: ', OutputDataFolder)} );
%Get List of Files From Input Folder
%Set status message and disable buttons
set(handles.pushbutton1,'Enable','off') 
set(handles.pushbutton2,'Enable','off') 
set(handles.pushbutton4,'Enable','off')     
set(handles.text2, 'String', 'Data compression in progress...');
pause(0.5);
ParseThroughFolder(InputDataFolder,OutputDataFolder);
set(handles.pushbutton1,'Enable','on') 
set(handles.pushbutton2,'Enable','on') 
set(handles.pushbutton4,'Enable','on')     
set(handles.text2, 'String', 'Data compression complete');

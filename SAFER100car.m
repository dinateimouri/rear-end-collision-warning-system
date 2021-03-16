function varargout = SAFER100car(varargin)
% SAFER100CAR M-file for SAFER100car.fig
%      SAFER100CAR, by itself, creates a new SAFER100CAR or raises the existing
%      singleton*.
%
%      H = SAFER100CAR returns the handle to a new SAFER100CAR or the handle to
%      the existing singleton*.
%
%      SAFER100CAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAFER100CAR.M with the given input arguments.
%
%      SAFER100CAR('Property','Value',...) creates a new SAFER100CAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAFER100car_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAFER100car_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAFER100car

% Last Modified by GUIDE v2.5 15-Mar-2010 08:47:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SAFER100car_OpeningFcn, ...
    'gui_OutputFcn',  @SAFER100car_OutputFcn, ...
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


% --- Executes just before SAFER100car is made visible.
function SAFER100car_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAFER100car (see VARARGIN)


sensorsLabels=[{'webfileid'},{'event start'},{'event end'},{'speed'},{'long accel'},{'accel gyro'},{'brake pedal'},{'left turn signal'},{'right turn signal'},{'throttle'},{'front radar'},{'rear radar'},{'ligh'},];

timeSeriesLabels=[{'Trip Identifier'},{'Sync'},{'Time'},{'Gas pedal position'},{'Speed, vehicle composite'},{'Speed, GPS horizontal'},...
    {'Yaw rate'},{'Heading, GPS'},{'Lateral acceleration'},{'Longitudinal acceleration'},{'Lane Markings, Continuity, Left Side Left Line'},...
    {'Lane Markings, Continuity, Left Side Right Line'},{'Lane Markings, Continuity, Right Side, Left Line'},{'Lane Markings, Continuity, Right Side, Right Line'},...
    {'Lane Markings, distance left'},{'Lane Markings, distance right'},{'Lane Markings, type left'},{'Lane Markings, type right'},...
    {'Lane markings, probability left'},{'Lane markings, probability right'},{'Radar, forward, ID'},...
    {'Radar, rearward, ID'},{'Radar, forward, range'},{'Radar, rearward, range'},{'Radar, forward, range rate'},{'Radar, rearward, range rate'},...
    {'Radar, forward azimuth'},{'Radar, rearward azimuth'},{'Light intensity'},{'Brake on off'},{'Turn signal state'}];

timeSeriesSize=[ones(20,1);7*ones(8,1);ones(3,1)];

handles.sensorsLabels=sensorsLabels;
handles.timeSeriesLabels=timeSeriesLabels;
handles.timeSeriesSize=timeSeriesSize;
handles.current_dir=pwd;

safer_logo=imread('safer.jpg');
image(safer_logo,'Parent',handles.axes4)
set(handles.axes4,'Visible','off','Interruptible','off','HitTest','off','DrawMode','fast');
set(handles.figure1,'CurrentAxes',handles.axes1);

set(handles.figure1,'Name','SAFER100Car NatWare v1.2')




% Choose default command line output for SAFER100car
handles.output = hObject;

if nargin == 3,
    initial_dir = pwd;
elseif nargin > 4
    if strcmpi(varargin{1},'dir')
        if exist(varargin{2},'dir')
            initial_dir = varargin{2};
        else
            errordlg('Input argument must be a valid directory','Input Argument Error!')
            return
        end
    else
        errordlg('Unrecognized input argument','Input Argument Error!');
        return;
    end
end

guidata(hObject, handles);
% Populate the listbox
load_listbox(hObject,initial_dir,handles)

% Update handles structure


% UIWAIT makes SAFER100car wait for user response (see UIRESUME)



% --- Outputs from this function are returned to the command line.
function varargout = SAFER100car_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data100Car


get(handles.figure1,'SelectionType');
if strcmp(get(handles.figure1,'SelectionType'),'open')
    index_selected = get(handles.listbox1,'Value');
    file_list = get(handles.listbox1,'String');
    filename = file_list{index_selected};
    if  handles.is_dir(handles.sorted_index(index_selected))
        current_folder=pwd;
        cd (handles.current_dir)
        cd (filename)
        load_listbox(hObject,pwd,handles)
        cd(current_folder);
    else
        [path,name,ext,ver] = fileparts(filename);
        switch ext
            
            case '.mat'
                load([handles.current_dir,'\',filename])
                try
                    CurrentEvent=int2str(Data100Car.ID);
                    set(handles.text2, 'String', CurrentEvent);
                    set(handles.listbox2,'String',handles.timeSeriesLabels,'Value',1)
                    updateValues(str2num(CurrentEvent),handles);
                catch
                    warndlg('This file does not contain a 100-Car-Study event', 'Warning');
                end
            otherwise
                try
                    open(filename)
                catch
                    errordlg('File Type Error')
                end
        end
    end
end


function load_listbox(hObject,dir_path,handles)
handles.current_dir=dir_path;
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(hObject, handles)
set(handles.listbox1,'String',handles.file_names,...
    'Value',1)
set(handles.text1,'String',pwd)

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


function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data100Car

% Plots time series data
get(handles.figure1,'SelectionType');
set(handles.figure1,'CurrentAxes',handles.axes1);
if strcmp(get(handles.figure1,'SelectionType'),'open')
    index_selected = get(handles.listbox2,'Value');
    signal_list = get(handles.listbox2,'String');
    signalName = signal_list{index_selected};
    signalSize=handles.timeSeriesSize(index_selected);
    startfrom=  sum(handles.timeSeriesSize(1:index_selected-1))+1;
    endto=  (sum(handles.timeSeriesSize(1:index_selected-1))+handles.timeSeriesSize(index_selected));
    PlotChildren=get(handles.axes1,'Children');
    delete(PlotChildren)
    hold all
    CurrentDataSplit=Data100Car.TimeSeries(:,startfrom:endto);
    
    plot(handles.axes1, CurrentDataSplit);
    if get(handles.radiobutton3,'Value')==1
        current_event=str2num(get(handles.text2,'String'));
        
        startEvent=find(Data100Car.TimeSeries(:,2)==Data100Car.Video.start);
        if isempty(startEvent), startEvent=1;,end;
        endEvent=find(Data100Car.TimeSeries(:,2)==Data100Car.Video.end);
        Xaxes=get(handles.axes1,'Xlim');
        Yaxes=get(handles.axes1,'Ylim');
        try
        rh=rectangle('Position',[startEvent,Yaxes(1), endEvent-startEvent, Yaxes(2)-Yaxes(1)],...
            'LineStyle',':','EdgeColor',[0.8 0.2 0.2], 'LineWidth',2);
        end
    end
    
    if get(handles.radiobutton4,'Value')==1
        Xaxes=get(handles.axes1,'Xlim');
        Yaxes=get(handles.axes1,'Ylim');
        current_event=str2num(get(handles.text2,'String'));
        
        
        %look for all glances
        for i=1:length(Data100Car.Glance)
            if (Data100Car.Glance(i).start==0), start_glance(i)=1;
            else
                start_glance(i)=find(Data100Car.TimeSeries(:,2)==Data100Car.Glance(i).start);
                if isempty(start_glance(i)), start_glance(i)=1;end;
            end
            stop_glance(i)=find(Data100Car.TimeSeries(:,2)==Data100Car.Glance(i).stop);
            ph(i)=patch([start_glance(i),start_glance(i),stop_glance(i),stop_glance(i)],...
                [Yaxes(1),Yaxes(2),Yaxes(2),Yaxes(1)],'g','FaceAlpha',0.2,'FaceColor',[0 0 0],'EdgeColor','none');
            
             switch lower(char(Data100Car.Glance(i).location))
                case('forward')
                    set(ph(i),'FaceColor',[0 1 0])
                case{'interior object','center stack','instrument cluster'}
                    set(ph(i),'FaceColor',[1 0 0])
                case{'left window','right window'}
                    set(ph(i),'FaceColor',[0 0 1])
                case{'rearview mirror','left mirror','right mirror'}
                    set(ph(i),'FaceColor',[0 1 1])
                case{'right forward','left forward'}
                    set(ph(i),'FaceColor',[1 1 0])
                case{'cell_phone','passenger'}
                    set(ph(i),'FaceColor',[1 0 1])
                case{'eyes closed'}
                    set(ph(i),'FaceColor',[0 0 0])
                case{'no video'}
                    set(ph(i),'FaceColor',[1 1 1])
            end
            
        end
        
    end
    
end

function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function GUI100Car_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Add the current directory to the path, as the pwd might change thru' the
% gui. Remove the directory from the path when gui is closed
% (See figure1_DeleteFcn)
setappdata(hObject, 'StartPath', pwd);
addpath(pwd);


% --- Executes during object deletion, before destroying properties.
function GUI100Car_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove the directory added to the path in the figure1_CreateFcn.
if isappdata(hObject, 'StartPath')
    rmpath(getappdata(hObject, 'StartPath'));
end


function [Currenteyeglance]=findevent(eyeglance,CurrentEvent)
Currenteyeglance=[];
for i=1:length(eyeglance)
    eyeglanceLine=char(eyeglance(i));
    if str2num(eyeglanceLine(1:4))==CurrentEvent
        Currenteyeglance=eyeglanceLine;
    end
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function []=updateValues(event, handles)

global Data100Car

videofields=[{'ID'},{'vehicle_webid'},{'start'},{'end'},{'severity'},...
    {'subject_ID'},{'age'},{'gender'},{'nature'},{'incident_type'},...
    {'pre_incident_maneuver'},{'maneuver_judgment'},{'precipitating_event'},{'driver_reaction'},{'post_maneuver_control'},...
    {'driver_behaviour_1'},{'driver_behaviour_2'},{'driver_behaviour_3'},{'driver_impairments'},{'infrastructure'},...
    {'distraction_1'},{'distraction_1_start_sync'},{'distraction_1_end_sync'},...
    {'distraction_1_outcome'},{'distraction_2'},{'distraction_2_start_sync'},...
    {'distraction_2_end_sync'},{'distraction_2_ouctome'},{'distraction_3'},...
    {'distraction_3_start_sync'},{'distraction_3_end_sync'},{'distraction_3_outcome'},...
    {'hands_on_wheel'},{'vehicle_contributing_factors'},{'visual_obstructions'},{'surface_condition'},...
    {'traffic_flow'},{'travel_lanes'},{'traffic_density'},{'traffic_control'},{'relation_to_junction'},...
    {'alignment'},{'locality'},{'lighting'},{'weather'},...
    {'driver_seatbelt_use'},{'number_of_other_vehicles'},{'fault'},{'vehicle_2_location'},{'vehicle_2_type'},...
    {'vehicle_2_maneuver'},{'vehicle_2_driver_reaction'},{'vehicle_3_location'},{'vehicle_3_type'},{'vehicle_3_maneuver'},{'vehicle_3_driver_reaction'},];

S=[];


% Event type
set(handles.text23,'String',Data100Car.Video.severity)


% Narratives
set(handles.text3,'String',Data100Car.Narratives)

% Sensors info
if Data100Car.Sensor.speed == 0
    set(handles.text4,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text4,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.long_accel == 0
    set(handles.text5,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text5,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.accel_gyro == 0
    set(handles.text6,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text6,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.brake_pedal == 0
    set(handles.text7,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text7,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.left_turn_signal == 0
    set(handles.text8,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text8,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.right_turn_signal == 0
    set(handles.text9,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text9,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.throttle == 0
    set(handles.text10,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text10,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.front_radar == 0
    set(handles.text11,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text11,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.rear_radar == 0
    set(handles.text12,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text12,'ForegroundColor',[0 0 0]);
end

if Data100Car.Sensor.light == 0
    set(handles.text13,'ForegroundColor',[0.7 0.7 0.7]);
else
    set(handles.text13,'ForegroundColor',[0 0 0]);
end


%Glance info
k=1;
for i=1:length(Data100Car.Glance)
    S{k}=['Glance ', num2str(i)];
    S{k+1}=num2str(Data100Car.Glance(i).start);
    S{k+2}=num2str(Data100Car.Glance(i).stop);
    S{k+3}=num2str(Data100Car.Glance(i).duration);
    S{k+4}=char(Data100Car.Glance(i).location);
    S{k+5}='-';
    k=k+6;
end

set(handles.listbox4,'String',S);

%Video info
k=1;
for i=1:56
    switch int2str(i)
        case {'1' '2' '3' '4' '6' '7' '22' '23' '26' '27' '30' '31' '38'...
                '47'}
            eval(['S2{i}=num2str(Data100Car.Video.',char(videofields(i)),');']);
            S2{i}=[char(videofields(i)),' = ',char(S2{i})];
        case {'5','8','9','10','11','12','13','14','15','16','17','18',...
                '19','20','21','24','25','28','29','32','33','34','35','36',...
                '37','39','40','41','42','43','44','45','46','48','49','50',...
                '51','52','53','54','55','56'}
            eval(['S2{i}=char(Data100Car.Video.',char(videofields(i)),');']);
            S2{i}=[char(videofields(i)),' = ',char(S2{i})];
    end
end

set(handles.listbox3,'String',S2);




% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Text='To get started, use the file browser (top left) to load a .mat file containing 100 Car data. Double-click on the signals (bottom left) to plot them. Use the plot controls to 1) plot the event in time, and 2) plot glances. Glances are color coded (see documentation). Sensors operation (right), gray: not operational, black: operational. In the middle of the screen you can find 1) the description of the event, 2) video annotations info, and 3) details on glances.';
h = helpdlg(Text,'GUI100Car HELP!');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Text='This tool was developed by Marco Dozza at SAFER Chalmers University of Technology (http://www.chalmers.se/safer/EN) in March 2010, all rights reserved. The Swedish National Strategic Transport grant and BASFOT2 project supported the development of this tool. The 100Car data was made available by the Virginia Tech Transportation Institute VTTI (http://www.access.vtti.vt.edu/)' ;
h=msgbox(Text,'About SAFER100Car v1.2');

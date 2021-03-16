%% comments
%Rear End Striking(conflict with a lead vehicle) ___ Just Near Crash 
%Just driver_reaction = braking(no lockup) (does not include Steering)
%Preprocessed DataSet
%containing precipitating Event Time

%based on this Paper : What factors influence drivers’ response time for
%evasive maneuvers in real traffic ?

%The most relevant (closest range) target was used to compute time-to-collision

%based on this page(203 / 856): The 100-Car Naturalistic Driving Study ,
%Phase II – Results of the 100-Car Field Experiment

%computes udi,Ta,Tr

%random 

%% constants
RT = 2; %Response Time
MAX_ACC_DEC = 11.48; % 3.5 m/s^2 =  f/s^2

%% code

load Event
EventType = cell(1,numel(Event));
EventID = zeros(1,numel(Event));
for i=1:numel(Event)
    EventType{i} = Event(i).Video.incident_type;
    EventID(i) = Event(i).ID;
end
%EventType{1};

RearEndStrikingEventType = cellfun(@isequal,EventType,repmat({'Rear-end striking'},1,numel(EventType)));
for i=1:numel(RearEndStrikingEventType)
    if RearEndStrikingEventType(i)==1
        if strcmp('Braking(no lockup)' , Event(i).Video.driver_reaction) && Event(i).Sensor.front_radar==1 && Event(i).Sensor.speed==1 && Event(i).Sensor.long_accel==1 && strcmp('Near Crash' , Event(i).Video.severity)
            RearEndStrikingEventType(i)=1;
        else 
            RearEndStrikingEventType(i)=0;
        end 
    end
end
TempID = find(RearEndStrikingEventType);
MyResultID = EventID(TempID);

cd NearCrashes

[v,delta_x,delta_v,ttc,tg,acc,pre_acc,delta_acc,udi,Ta,Tr,warning]= deal(1,2,3,4,5,6,7,8,9,10,11,12); 
MyDataSet_2 = [];
for i=1:numel(MyResultID)
    
    ID = num2str(MyResultID(i));
    load (ID);
    
    %% choose rows between precipitating Event Time
    start_row = find(Data100Car.TimeSeries(:,2)==Data100Car.Video.start);
    start_time = Data100Car.TimeSeries(start_row,3);
    end_row = find(Data100Car.TimeSeries(:,2)==Data100Car.Video.end);
    end_time = Data100Car.TimeSeries(end_row,3);
    
    %v
    tempMatrix = Data100Car.TimeSeries([1:end_row],5);
    helpFindMatrixContainigPrecipitatingEvent = Data100Car.TimeSeries([start_row:end_row],1);
          
    %% delta_x = x(leader)-x(follower)
    %delta_v = v(leader)-v(follower)
    
    %(based on this paper : A rule-based neural network
    %approach to model driver naturalistic behavior in traffic)
    
    AMatrix = Data100Car.TimeSeries([1:end_row],[35:41]);
    AMatrix(AMatrix == 0) = Inf;
    [value,column] = min(AMatrix,[],2);
    tempMatrix(:,delta_x) = value; %add delta_x column
    
    BMatrix = Data100Car.TimeSeries([1:end_row],[49:55]);
    idx = sub2ind(size(BMatrix), 1:size(BMatrix, 1), column');
    valuevalue = BMatrix(idx)';
    tempMatrix(:,delta_v) = valuevalue; %add delta_v column
    
    %% find TTC = (delta_x / - delta_v ) & TG =(delta_x / v)
    tempMatrix(:,ttc) = tempMatrix(:,delta_x)./(-1 * tempMatrix(:,delta_v));
    tempMatrix(:,tg) = tempMatrix(:,delta_x) ./ tempMatrix(:,v);
    
    %% find previous_acc
    tempArray = Data100Car.TimeSeries([1:end_row],10);
    tempMatrix(:,acc) = tempArray;
    tempTempArray = circshift(tempArray,[1 1]); 
    tempMatrix(:,pre_acc) = tempTempArray;
    
    %% find delta_acc = (now_acc - previous_acc)
    tempMatrix(:,delta_acc) = tempMatrix(:,acc)-tempMatrix(:,pre_acc); 
    %if (now_acc - previous_acc)>=0 then +1 else 0
    %tempMatrix(:,delta_acc) = (tempMatrix(:,delta_acc)>=0);
    
    %% udi  (ft)
    v_leader = tempMatrix(:,v) + tempMatrix(:,delta_v);
    v_leader = v_leader * 1.46; % 1 mph = 1.46 fps 
    sdl = (v_leader .* v_leader)/(2*MAX_ACC_DEC);
    
    v_follower = tempMatrix(:,v);
    v_follower = v_follower *1.46; % 1 mph = 1.46 fps 
    sdf = ((v_follower .* v_follower)/(2*MAX_ACC_DEC))+ (v_follower * RT);
    
    %d0 = 3.28; %security heading offset - constant - 1m = 3.28ft
    % lp =  ; %length of preceding vehicle
    tempMatrix(:,udi) = sdl - sdf + tempMatrix(:,delta_x) ;
    
    %% Ta & Tr
    DF = tempMatrix(:,delta_x);
    SF = tempMatrix(:,v)*1.46; % 1 mph = 1.46 fps 
    sb = 3.28; %1m= 3.28ft
    sbArray = ones(size(tempMatrix(:,v),1),1);
    sbArray = sbArray * sb;
    tempMatrix(:,Ta) = (DF - (RT*SF)- sbArray)./(SF); 
    tempMatrix(:,Tr) = (SF)/(2*MAX_ACC_DEC);
    
    %% find warning
    column = zeros (end_row , 1);
    column([(1:start_row -1)],1) = 0.5;
    column([start_row:end],1) = 1;
    tempMatrix(:,warning) = column;
  
    %% find reaction time of driver
%     [val,idx]=min(tempMatrix([start_row:end_row],acc),[],1);
%     idx = idx + start_row;
      removeableRows = [];
%     removeableRows = [removeableRows;(idx:end_row)'];
    %% Preprocessing DataSet
    
    %remove rows that probably speed's sensor is off
    %find min acc
    %minAcc = min (tempMatrix(:,acc));
    %result = -0.5918 = -0.6(g) => worst case "decreased v = -15" mph
    temporalArray = tempMatrix(:,v);
    temporalTemporalArray = circshift(temporalArray,[1 1]); 
    pre_v = temporalTemporalArray;
    deltaV = tempMatrix(:,v) - pre_v ;
    Index = find(deltaV < -15);
    
    for r=1:numel(Index)
        rowNumber = Index(r);
        while tempMatrix(rowNumber,v) <=0
            removeableRows = [removeableRows;rowNumber];
            rowNumber = rowNumber +1;
            if(rowNumber > end_row )
                break ;
            end
        end
    end
    %remove rows that their forwardRadarID equals zero
    %based on paper :(A rule-based neural network ...)
    forwardRadarID = Data100Car.TimeSeries([1:end_row],21);
    removeableRows = [removeableRows;find(forwardRadarID == 0)];
%     remove rows that v =0 % after stopping 
%     speed = Data100Car.TimeSeries([1:end_row],5);
%     removeableRows = [removeableRows;find(speed == 0)];
    removeRow = unique(removeableRows);
    tempMatrix(removeRow,:) = [];
   
    %remove first row
    if size(helpFindMatrixContainigPrecipitatingEvent,1) ~= 0 %because of event such as 8345 that does not have precipitating event's lines
       % tempMatrix(1,:) = [];
        MyDataSet_2 = [MyDataSet_2;tempMatrix];
    end
end

%%remove rows containing 'Inf' & NaN
MyDataSet_2 = MyDataSet_2(~any(isinf(MyDataSet_2),2),:);
MyDataSet_2 = MyDataSet_2(~any(isnan(MyDataSet_2),2),:);

%% convert units
%v : 1 mph = 0.44 m/s
MyDataSet_2(:,v)= MyDataSet_2(:,v)*0.44;

%delta_x : 1 ft = 0.3 meter
MyDataSet_2(:,delta_x)= MyDataSet_2(:,delta_x)*0.3;

%delta_v : 1 ft/s = 0.3 meter/s
MyDataSet_2(:,delta_v)= MyDataSet_2(:,delta_v)*0.3;

%ttc : 1 ft/(ft/s) = 1 s
%ttc : without change

%tg : 1 ft/mph = 0.3/0.44 s = 0.68 s
MyDataSet_2(:,tg)= MyDataSet_2(:,tg)*0.68;

%acc : 1 g = 9.8 m/s^2
MyDataSet_2(:,[pre_acc acc delta_acc])= MyDataSet_2(:,[pre_acc acc delta_acc])*9.8;

%udi : 1 ft = 0.3 meter
MyDataSet_2(:,udi) = MyDataSet_2(:,udi)*0.3;

%% remove rows containing 'Inf' & NaN
MyDataSet_2 = MyDataSet_2(~any(isinf(MyDataSet_2),2),:);
MyDataSet_2 = MyDataSet_2(~any(isnan(MyDataSet_2),2),:);

%% feature scale
% MyDataSet_2(:,v) = (MyDataSet_2(:,v)-min(MyDataSet_2(:,v)))/(max(MyDataSet_2(:,v))-min(MyDataSet_2(:,v)));
% MyDataSet_2(:,delta_x) = (MyDataSet_2(:,delta_x)-min(MyDataSet_2(:,delta_x)))/(max(MyDataSet_2(:,delta_x))-min(MyDataSet_2(:,delta_x)));
% MyDataSet_2(:,delta_v) = (MyDataSet_2(:,delta_v)-min(MyDataSet_2(:,delta_v)))/(max(MyDataSet_2(:,delta_v))-min(MyDataSet_2(:,delta_v)));
% MyDataSet_2(:,ttc) = (MyDataSet_2(:,ttc)-min(MyDataSet_2(:,ttc)))/(max(MyDataSet_2(:,ttc))-min(MyDataSet_2(:,ttc)));
% MyDataSet_2(:,tg) = (MyDataSet_2(:,tg)-min(MyDataSet_2(:,tg)))/(max(MyDataSet_2(:,tg))-min(MyDataSet_2(:,tg)));
% MyDataSet_2(:,pre_acc) = (MyDataSet_2(:,pre_acc)-min(MyDataSet_2(:,pre_acc)))/(max(MyDataSet_2(:,pre_acc))-min(MyDataSet_2(:,pre_acc)));
% MyDataSet_2(:,acc) = (MyDataSet_2(:,acc)-min(MyDataSet_2(:,acc)))/(max(MyDataSet_2(:,acc))-min(MyDataSet_2(:,acc)));
% MyDataSet_2(:,delta_acc) = (MyDataSet_2(:,delta_acc)-min(MyDataSet_2(:,delta_acc)))/(max(MyDataSet_2(:,delta_acc))-min(MyDataSet_2(:,delta_acc)));
% MyDataSet_2(:,udi) = (MyDataSet_2(:,udi)-min(MyDataSet_2(:,udi)))/(max(MyDataSet_2(:,udi))-min(MyDataSet_2(:,udi)));

%% just need ttc&tg&pre_acc&acc
MyDataSet_2(:,[pre_acc,delta_acc,Ta,Tr])=[];

p = randperm(size(MyDataSet_2,1));
data = MyDataSet_2(p,:);

save data data
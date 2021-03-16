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

[v,delta_x,delta_v,ttc,tg,mazda,sda,path,honda,GandH,warning]= deal(1,2,3,4,5,6,7,8,9,10,11); 
MyDataSet_2 = [];
for i=1:numel(MyResultID)
    
    ID = num2str(MyResultID(i));
    load (ID);
    
    %% choose rows between precipitating Event Time
    start_row = find(Data100Car.TimeSeries(:,2)==Data100Car.Video.start);
    start_time = Data100Car.TimeSeries(start_row,3);
    end_row = find(Data100Car.TimeSeries(:,2)==Data100Car.Video.end);
    end_time = Data100Car.TimeSeries(end_row,3);
     
    if ~isempty(end_row)
    
        %v
        tempMatrix = Data100Car.TimeSeries([1:end_row],5);
        helpFindMatrixContainigPrecipitatingEvent = Data100Car.TimeSeries([start_row:end_row],1);

        %% delta_x = x(leader)-x(follower)
        %delta_v = v(leader)-v(follower)

         %(based on this paper : A rule-based neural network
        %approach to model driver naturalistic behavior in traffic)

        %% filter data

        targetID = Data100Car.TimeSeries([1:end_row],[21:27]);
        targetID2 = targetID>0;
        range = Data100Car.TimeSeries([1:end_row],[35:41]);
        range2 = range*0.3048; % ft to meter
        range2(range2==0)=NaN;
        range3 = range2<= 120;
        azimuth = Data100Car.TimeSeries([1:end_row],[63:69]);
        sinazimuth = sin(azimuth);
        prod = range2.*sinazimuth;
        %prod(prod==0)=NaN;  % important , notice 
        prod2 = abs(prod)< 1.9;
        result = zeros(end_row,7); % 7 potential target
        for i=1:end_row
            for j=1:7
                if (targetID2(i,j)==1 & range3(i,j)==1 & prod2(i,j)==1)
                    result(i,j)= range(i,j); % because we need range soon ;)
                else
                    result(i,j) = NaN; %becasue we need to use min , so these must be NaN , without effect
                end
            end
        end

        % The most relevant (closest range) target was used 
        for i=1:end_row
            temp_row = result(i,:);
            [value,index] = min(temp_row);  % value is minimum range
            tempMatrix(i,delta_x) = value;
            tempMatrix(i,delta_v) = Data100Car.TimeSeries(i,(48+index));  %deltaV columns are : [49:55]
        end


        %% find TTC = (delta_x / - delta_v ) & TG =(delta_x / v)
        tempMatrix(:,ttc) = tempMatrix(:,delta_x)./(-1 * tempMatrix(:,delta_v));
        tempMatrix(:,tg) = tempMatrix(:,delta_x) ./ tempMatrix(:,v);
        
        %% udi  (m)

%          v_f = tempMatrix(:,v)*0.44704; %m/s
%          v_l = (tempMatrix(:,delta_v)*0.3)+(tempMatrix(:,v)*0.44704); %m/s
%          tempMatrix(:,udi) = 0.142*(v_l.^2)+(tempMatrix(:,delta_x)*0.3)-(0.142*(v_f.^2))-(v_f*2);

        %% mazda(m)
        v_f = tempMatrix(:,v)*0.44704; %m/s
        v_l = (tempMatrix(:,delta_v)*0.3)+(tempMatrix(:,v)*0.44704); %m/s
        tempMatrix(:,mazda)= 0.5*(((v_f.^2)/6)-((v_l.^2)/8))+ (0.1*v_f)+ (0.6*tempMatrix(:,delta_v)*0.3)+5; %m
        
        %% SDA(m)
        tempMatrix(:,sda)=(v_f*2)+(0.5*((v_f.^2)/3.5))-(0.5*((v_l.^2)/3.5)); %m
        
        %% path(m)
        tempMatrix(:,path)=((0.5/6)*((v_f.^2)-(v_l.^2)))+(1.2*v_f)+5;  %m
        
        %% Honda(m)
        tempMatrix(:,honda)=(4*tempMatrix(:,delta_v)*0.3)+6.2;  %m
        
        %% GandH (m)
        tempMatrix(:,GandH)= (4*tempMatrix(:,delta_v)*0.3)+(0.4905*v_f); %m

        %% find warning
        column = zeros (end_row , 1);
        column([(1:start_row -1)],1) = 0.5;
        column([start_row:end],1) = 1;
        tempMatrix(:,warning) = column;

        %% 
          removeableRows = [];
 
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
end

%%remove rows containing 'Inf' & NaN
MyDataSet_2 = MyDataSet_2(~any(isinf(MyDataSet_2),2),:);
MyDataSet_2 = MyDataSet_2(~any(isnan(MyDataSet_2),2),:);

%% convert units
%v : 1 mph = 1.60934 km/h
MyDataSet_2(:,v)= MyDataSet_2(:,v)*1.60934;

%delta_x : 1 ft = 0.3 meter
MyDataSet_2(:,delta_x)= MyDataSet_2(:,delta_x)*0.3;

%delta_v : 1 ft/s = 0.3 meter/s
MyDataSet_2(:,delta_v)= MyDataSet_2(:,delta_v)*0.3;

%ttc : 1 ft/(ft/s) = 1 s
%ttc : without change

%tg : 1 ft/mph = 0.3/0.44 s = 0.68 s
MyDataSet_2(:,tg)= MyDataSet_2(:,tg)*0.68;


%% remove rows containing 'Inf' & NaN
MyDataSet_2 = MyDataSet_2(~any(isinf(MyDataSet_2),2),:);
MyDataSet_2 = MyDataSet_2(~any(isnan(MyDataSet_2),2),:);

%% feature scale
% MyDataSet_2(:,v) = (MyDataSet_2(:,v)-min(MyDataSet_2(:,v)))/(max(MyDataSet_2(:,v))-min(MyDataSet_2(:,v)));
% MyDataSet_2(:,delta_x) = (MyDataSet_2(:,delta_x)-min(MyDataSet_2(:,delta_x)))/(max(MyDataSet_2(:,delta_x))-min(MyDataSet_2(:,delta_x)));
% MyDataSet_2(:,delta_v) = (MyDataSet_2(:,delta_v)-min(MyDataSet_2(:,delta_v)))/(max(MyDataSet_2(:,delta_v))-min(MyDataSet_2(:,delta_v)));
% MyDataSet_2(:,ttc) = (MyDataSet_2(:,ttc)-min(MyDataSet_2(:,ttc)))/(max(MyDataSet_2(:,ttc))-min(MyDataSet_2(:,ttc)));
% MyDataSet_2(:,tg) = (MyDataSet_2(:,tg)-min(MyDataSet_2(:,tg)))/(max(MyDataSet_2(:,tg))-min(MyDataSet_2(:,tg)));
% MyDataSet_2(:,udi) = (MyDataSet_2(:,udi)-min(MyDataSet_2(:,udi)))/(max(MyDataSet_2(:,udi))-min(MyDataSet_2(:,udi)));

%%

%p = randperm(size(MyDataSet_2,1));
%data = MyDataSet_2(p,:);

data= MyDataSet_2;

save data data


%%
warndata = data(data(:,end)==1,:);
safedata = data(data(:,end)==0.5,:);

save safedata safedata
save warndata warndata



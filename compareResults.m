clc
clear all

%% compare results
[v,delta_x,delta_v,ttc,tg,udi,mazda,sda,path,honda,GandH,warning]= deal(1,2,3,4,5,6,7,8,9,10,11,12); 

cd NearCrashes
load safedata
load warndata

%% kinematic based

% % mazda
% warnmazda = warndata((warndata(:,delta_x)<= warndata(:,mazda)),:);
% safemazda = safedata((safedata(:,delta_x)> safedata(:,mazda)),:);
% %mazdadeghat = (size(warnmazda,1)+size(safemazda,1))/(size(warndata,1)+size(safedata,1))
% mazdaHasasiyat = size(warnmazda,1)/size(warndata,1)
% mazdaShafafiyat = size(safemazda,1)/size(safedata,1)
% 
% % sda
% warnsda = warndata((warndata(:,delta_x)<= warndata(:,sda)),:);
% safesda = safedata((safedata(:,delta_x)> safedata(:,sda)),:);
% %sdadeghat = (size(warnsda,1)+size(safesda,1))/(size(warndata,1)+size(safedata,1))
% sdaHasasiyat = size(warnsda,1)/size(warndata,1)
% sdaShafafiyat = size(safesda,1)/size(safedata,1)
% 
% 
% % path
% warnpath = warndata((warndata(:,delta_x)<= warndata(:,path)),:);
% safepath = safedata((safedata(:,delta_x)> safedata(:,path)),:);
% %pathdeghat = (size(warnpath,1)+size(safepath,1))/(size(warndata,1)+size(safedata,1))
% pathHasasiyat = size(warnpath,1)/size(warndata,1)
% pathShafafiyat = size(safepath,1)/size(safedata,1)

%% perceptual based

% %TTC
% warnttc = warndata((warndata(:,ttc)>=0 & warndata(:,ttc)<=2.2),:);
% safettc = safedata((safedata(:,ttc)>2.2 | safedata(:,ttc)<0),:); 
% ttcHasasiyat = size(warnttc,1)/size(warndata,1)
% ttcShafafiyat = size(safettc,1)/size(safedata,1)


% %Honda 
% warnhonda = warndata((warndata(:,delta_x)<= warndata(:,honda)),:);
% safehonda = safedata((safedata(:,delta_x)> safedata(:,honda)),:); 
% hondaHasasiyat = size(warnhonda,1)/size(warndata,1)
% hondaShafafiyat = size(safehonda,1)/size(safedata,1)
% 
% 
% %Hirst&Graham 
% warnGandH = warndata((warndata(:,delta_x)<= warndata(:,GandH)),:);
% safeGandH = safedata((safedata(:,delta_x)> safedata(:,GandH)),:); 
% GandHHasasiyat = size(warnGandH,1)/size(warndata,1)
% GandHShafafiyat = size(safeGandH,1)/size(safedata,1)

%TG
warntg = warndata(warndata(:,tg)<=3.21,:);
safetg = safedata(safedata(:,tg)>3.21,:);
tgHasasiyat = size(warntg,1)/size(warndata,1)
tgShafafiyat = size(safetg,1)/size(safedata,1)

% %TTCTGFIS
% ttctgFIS = readfis('CWS-TTCTG.fis');
% 
% warndata(warndata(:,ttc)<0,ttc)= 10;
% safedata(safedata(:,ttc)<0,ttc)= 10;
% 
% temp = evalfis([warndata(:,ttc) warndata(:,tg)],ttctgFIS);
% warnttctgSize = sum(temp >= 0.5);
% ttctgHasasiyat = warnttctgSize/size(warndata,1)
% temptemp = evalfis([safedata(:,ttc) safedata(:,tg)],ttctgFIS);
% safettctgSize = sum(temptemp <= 0.5);
% ttctgShafafiyat = safettctgSize/size(safedata,1)










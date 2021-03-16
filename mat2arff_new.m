%http://tanviralamspace.blogspot.com/2011/10/matlab-matrix-to-weka-arff-for
%mat.html

% inputFormat ( matrix are tab seperated , last column indicates the label, This is for two class problem,
% for multiclass need to change the code in few lines)
% ======================================================================
% 5.0  6.5  7.9 +1
% 6.6  8.9  6.1 0.5
% code
% =======
% function matlabToarff


% convert matrix int arff(Attribute relation file format )format
clc;
fNameData = 'D:\MS-lessons\thesis\VirginaTechTransportationInstitute\File Exchange\SAFER100Car\SAFER100Car_v1.2___ MyWork\SAFER100Car_v1.2\NearCrashes\Steeringdata';
fNameARFF = 'D:\MS-lessons\thesis\VirginaTechTransportationInstitute\File Exchange\SAFER100Car\SAFER100Car_v1.2___ MyWork\SAFER100Car_v1.2\NearCrashes\Steeringdataweka.arff';

fidARFF = fopen( fNameARFF ,'w');
temp = load(fNameData);
tempnames = fieldnames(temp);
matrix = temp.(tempnames{1});
feature = matrix ( : , 1:end-1);
label = matrix (: , end) ;
noFeature = size(feature,2);
noSample = size(feature,1);

%%%%%%%%%% header

fprintf(fidARFF,'%s\n\n','@RELATION LNCRNAsequence');
for i=1:noFeature % noFeature
         fprintf(fidARFF,'%s\t%d\t%s\n' ,'@ATTRIBUTE' , i, 'NUMERIC' );
end
fprintf(fidARFF,'%s\n\n','@ATTRIBUTE class {+1,0.5}');

%%%%%%%%%%  data
fprintf(fidARFF,'%s\n','@DATA');
for r=1:noSample
     for c=1:noFeature
          fprintf(fidARFF,'%f,',matrix(r,c) );
     end
     if label(r)==1
            fprintf(fidARFF,'%s\n', '+1');
     else
            fprintf(fidARFF,'%s\n', '0.5');
     end
end

fclose(fidARFF);

% end
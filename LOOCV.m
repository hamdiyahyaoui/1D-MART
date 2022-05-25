% Copyright and terms of use (DO NOT REMOVE):
% The code is made freely available for non-commercial uses only, provided that the copyright 
% header in each file is not removed, and suitable citation(s) (see below) are made for papers 
% published based on the code.
%
% The code is not optimized for speed, and we are not responsible for any errors that might
% occur in the code.
%
% The copyright of the code is retained by the authors.  By downloading/using this code you
% agree to all the terms stated above.
%
% Hamdi Yahyaoui, Hosam AboElfotoh and Yanjun Shu 
% A Multilevel Adaptive Reduction Technique for Time Series (MART), Research Grant No. [SU02/20],
% Computer Science Department, Kuwait University.



 global TermSize TrainFile TestFile No_SeqOT No_SeqOS W

list={'50words', 'Adiac', 'Beef', 'BeetleFly', 'Car', 'CBF', 'CinC', 'Coffee', 'DiatomSizeReduction', 'ECG200', 'FaceAll', 'FaceFour', 'FISH', 'Gun_Point', 'Haptics', ...
    'ItalyPowerDemand',  'Lighting2', 'Lighting7', 'MALLAT', 'MedicalImages', 'MoteStrain', 'OliveOil', 'OSULeaf',  'SonyAIBORobotSurface', 'SonyAIBORobotSurfaceII', ...
    'SwedishLeaf', 'Symbols', 'synthetic_control', 'Trace', 'Two_Patterns', 'TwoLeadECG',  'uWaveGestureLibrary_X',  'wafer', 'WordsSynonyms', 'yoga'};
w=[90,59,6,16,18,3,410,12,3,12,7,10,25,6,5,5,3,5,20,25,12,6,19,7,6,13,10,10,5,9,3,7,38,10,106];


n=length(w);
Fold10Results_EU=zeros(n,10);
Fold10Results_Trend=zeros(n,10);
Fold10Results_Trend_tuningW=zeros(n,10);

ErrorRate=zeros(n,2);
err_EU=cell(n,1);
err_tuning=cell(n,1);


for i=1:n
    
    W=w(i);
    Data_Name=list{i};
    
    %For scale experiments
    %data1 = textread(strcat('E:\TrendCode\', list{i},'_TRAIN.txt'));
    %data2 = textread(strcat('E:\TrendCode\', list{i},'_TEST.txt'));
    
    %merge all cases together 
    TrainFile_I=strcat('E:\TrendCode\TRAIN\', list{i}, '_TRAIN.csv');
    TestFile_I=strcat('E:\TrendCode\TEST\', list{i}, '_TEST');
    data1 = csvread(TrainFile_I); 
    data2 = xlsread(TestFile_I);
    
    %% for scale experiments
    data3_n = [data1; data2];
    [scale_n, seriesLength]=size(data3_n(:, 2:end));
    num=ceil(scale_n*1);
    data3 = data3_n(1:num,:);
    label=data3(:,1);
   
    data3N=data3(:,2:end);
    
        for k=1:num
            data3N(k,:) = zscore(data3N(k,:));
        end
       
    
    %% LOO Cross Validation
    err=zeros(num,2);
    for j = 1:num
        delete('LOOTrain.xlsx'); delete('LOOTest.xlsx'); 
        test = j; 
        train = 1:num;
        train(j) =[];
        
        dataT=data3N(train, :);    % Train dataset
        xlswrite('LOOTrain.xlsx', dataT); 
        TrainFile='LOOTrain';
        dataS=data3N(test, :);          % Test dataset
        xlswrite('LOOTest.xlsx', dataS); 
        TestFile='LOOTest';
        class=label(train);            % Train cases' class
        truelabels=label(test);     % Test cases' class
        [No_SeqOT, lenT]=size(dataT);
        [No_SeqOS, lenS]=size(dataS);
        TermSize=floor(lenT/W);
         
        
        delete('SAXT85.xlsx'); delete('SEQT85.xlsx'); delete('BETAT85.xlsx'); delete('SDT85.xlsx');
        delete('SAXS85.xlsx'); delete('SEQS85.xlsx'); delete('BETAS85.xlsx'); delete('SDS85.xlsx');
         
      
       
        %------ euclidean distance=1-------------------------------%
        classout_eu = knnclassify_Mod(dataS, dataT, class,1,1);
        %CP_EU = classperf(truelabels, classout_eu);
        err(j,1)=classout_eu==truelabels;
        fprintf('The %f LOOCV \n', j);
        fprintf('%s EU Error rate  %f.\n', Data_Name, err(j,1));
        %------Trend distance=2------------------------------------%
        classout_trend = knnclassify_Mod(dataS, dataT, class,1,2);
        err(j,2)=classout_trend==truelabels;
        fprintf('%s Trend Error rate  %f.\n', Data_Name, err(j,2));
       
   
    end
    err_tuning{i}=err;
    ErrorRate(i,:)=sum(err_tuning{i,1})/length(err_tuning{i,1});
    
    
end

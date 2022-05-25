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



global TermSize TrainFile TestFile No_SeqOT No_SeqOS W Level

list={'50words', 'Adiac', 'Beef', 'BeetleFly', 'Car', 'CBF', 'CinC', 'Coffee', 'DiatomSizeReduction', 'ECG200', 'FaceAll', 'FaceFour', 'FISH', 'Gun_Point', 'Haptics', ...
    'ItalyPowerDemand',  'Lighting2', 'Lighting7', 'MALLAT', 'MedicalImages', 'MoteStrain', 'OliveOil', 'OSULeaf',  'SonyAIBORobotSurface', 'SonyAIBORobotSurfaceII', ...
    'SwedishLeaf', 'Symbols', 'synthetic_control', 'Trace', 'Two_Patterns', 'TwoLeadECG',  'uWaveGestureLibrary_X',  'wafer', 'WordsSynonyms', 'yoga'};
w=[2,18,6,14,16,4,8,10,8,2,2,8,14,8,6,8,14,10,6,6,4,4,10,2,4,12,4,26,10,6,4,8,4,10,6];
w_tuning=[90,59,6,16,18,3,410,12,3,12,7,10,25,6,5,5,3,5,20,25,12,6,19,7,6,13,10,10,5,9,3,7,38,10,106];


n=length(w);
Fold10Results_EU=zeros(n,10);
Fold10Results_Trend=zeros(n,10);
Fold10Results_Trend_tuningW=zeros(n,10);

ErrorRate=zeros(n,2);

err_tuning=cell(n,1);

err=cell(n, 1);
err_eu=cell(n,1);
ER=cell(n,1);

for i=33:n
    
    W=w_tuning(i);
    Data_Name=list{i};
    
    %%merge all cases together
    TrainFile_I=strcat('E:\TrendCode\TRAIN\', list{i}, '_TRAIN.csv');
    TestFile_I=strcat('E:\TrendCode\TEST\', list{i}, '_TEST');
    data1 = csvread(TrainFile_I); 
    data2 = xlsread(TestFile_I);
    data3= [data1; data2];
    label=data3(:,1);
   % indices = crossvalind('Kfold', label,10);
   % cp = classperf(label);
    [num, seriesLength]=size(data3(:, 2:end));
    
    %data3N=zscore(data3(:, 2:end));
    data3N=data3(:,2:end);
    
        for k=1:num
            data3N(k,:) = zscore(data3N(k,:));
        end
        
    
    %% LOO Cross Validation
    Level=4;
    err_EU=zeros(num, 1);
    err_K=zeros(num, Level);
    
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
        TermSize=floor(lenT/W)-1;
         
        
        delete('SAXT85.xlsx'); delete('SEQT85.xlsx'); delete('BETAT85.xlsx'); delete('SDT85.xlsx');
        delete('SAXS85.xlsx'); delete('SEQS85.xlsx'); delete('BETAS85.xlsx'); delete('SDS85.xlsx');
        
        delete('SAXT85K.xlsx'); delete('SEQT85K.xlsx'); delete('BETAT85K.xlsx'); delete('SDT85K.xlsx');
        delete('SAXS85K.xlsx'); delete('SEQS85K.xlsx'); delete('BETAS85K.xlsx'); delete('SDS85K.xlsx');
      
           level_K=1;
            %tic;
            %------ euclidean distance=1-------------------------------%
            classout_eu = knnclassify_Mod(dataS, dataT, class,1,1);
            %CP_EU = classperf(truelabels, classout_eu);
             err_EU(j,1)=classout_eu==truelabels;
            fprintf('The %f LOOCV ', j);
            %fprintf('%s EU Error rate  %f.\n', Data_Name, err(j,1));
            %------Trend distance=2------------------------------------%
            classout_trend = knnclassify_Mod(dataS, dataT, class,1,2);
            err_K(j,  level_K)=classout_trend==truelabels;
            %fprintf('%s Trend Error rate  %f.\n', Data_Name, err(j,2));
            %toc;
        
        
%         str11=dataS(1,:);
%         str_list1=dataT;
%         tic;
%         [dist_arr] = CP_MinDist3(str11, str_list1);
%         toc;
%         delete('SAXT85K.xlsx'); delete('SEQT85K.xlsx'); delete('BETAT85K.xlsx'); delete('SDT85K.xlsx');
%         delete('SAXS85K.xlsx'); delete('SEQS85K.xlsx'); delete('BETAS85K.xlsx'); delete('SDS85K.xlsx');
      
            level_K=level_K+1;
            TrendT=xlsread('SDT85.xlsx');
            TrendS=xlsread('SDS85.xlsx');
            [TrendNT]=TrendConcate(TrendT, TermSize);
            [TrendNS]=TrendConcate(TrendS, TermSize);
            idx=cellfun(@isstr,TrendNT);
            TrendNT(idx)=strcat('''', TrendNT(idx));
            xlswrite('SDT85K.xlsx',TrendNT);
            idx=cellfun(@isstr,TrendNS);
            TrendNS(idx)=strcat('''', TrendNS(idx));
            xlswrite('SDS85K.xlsx',TrendNS);
        %[~,TrendX,~]=xlsread('SDT85.xlsx');
        
            classout_trend = knnclassify_Mod(dataS, dataT, class,1,3);
            err_K(j,level_K)=classout_trend==truelabels;
            
             
             
       while(level_K<Level)
            level_K=level_K+1;
            dataTK=xlsread('SAXT85K.xlsx');
            dataSK=xlsread('SAXS85K.xlsx');
            delete('SAXT85.xlsx');
            delete('SAXS85.xlsx');
            delete('SAXT85K.xlsx');
            delete('SAXS85K.xlsx');
            xlswrite('SAXT85.xlsx', dataTK);
            xlswrite('SAXS85.xlsx', dataSK);
            [~,TrendT,~]=xlsread('SDT85K.xlsx');
            [~,TrendS,~]=xlsread('SDS85K.xlsx');
            delete('SDT85K.xlsx');
            delete('SDS85K.xlsx');
            [TrendNT]=TrendConcatek(TrendT, TermSize);
            [TrendNS]=TrendConcatek(TrendS, TermSize);
            idx=cellfun(@isstr,TrendNT);
            TrendNT(idx)=strcat('''', TrendNT(idx));
            xlswrite('SDT85K.xlsx',TrendNT);
            idx=cellfun(@isstr,TrendNS);
            TrendNS(idx)=strcat('''', TrendNS(idx));
            xlswrite('SDS85K.xlsx',TrendNS);
            
            classout_trend = knnclassify_Mod(dataS, dataT, class,1,3);
            err_K(j, level_K)=classout_trend==truelabels;
       end
        %[dist_arr_K] = CP_MinDist_K(str11, str_list1);
        
    end             
    
      ER{i,1}=err_K;
 end
            
        
        
        
        
        
   
%     end
%     err_tuning{i}=err;
%     ErrorRate(i,:)=sum(err_tuning{i,1})/length(err_tuning{i,1});
%      
    

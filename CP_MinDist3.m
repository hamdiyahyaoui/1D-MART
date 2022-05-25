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

function [dist_arr] = CP_MinDist3(str11, str_list1)
global TermSize TrainFile TestFile No_SeqOT No_SeqOS dataO str1111 SDTT W
[n, L]=size(str_list1); 
Terms=W;
segment=1:TermSize:L;
dist_arr=zeros(n,1);
N_Q=str11;
%L=length(N_Q);

if exist('SAXT85.xlsx', 'file')==0 
    tic;
    dataTTT = xlsread(TrainFile); 
    dataTT=dataTTT(:, 1:end);
%     for j=1:No_SeqOT
%         dataTT(j,:) = zscore(dataTT(j,:));
%     end
    % %--------- test for Q and R-----------%
    % No_SeqOT=1;
    % %---------Not test-------------------%
    [No_SeqOT, lenT]=size(dataTT);
    for SEQO=1:No_SeqOT
        X=Distance_Computation(dataTT(SEQO,:),TermSize);
        AT(SEQO,:)=X.m;  AAT(SEQO,:)=X.d;  AAAT(SEQO,:)=X.sq;  AAAAT(SEQO,:)=X.t;
    end
     xlswrite('SAXT85.xlsx',AT);   xlswrite('SEQT85.xlsx',AAT);  xlswrite('BETAT85.xlsx',AAAT);  xlswrite('SDT85.xlsx',AAAAT);
     SDTT.m= xlsread('SAXT85.xlsx');
     SDTT.d= xlsread('SEQT85.xlsx');
     SDTT.sq= xlsread('BETAT85.xlsx');
     SDTT.t= xlsread('SDT85.xlsx');
     toc;
end


if exist('SAXS85.xlsx', 'file')==0
    dataOO = xlsread(TestFile); 
    dataO=dataOO(:,1:end);
%     for j=1:No_SeqOS
%         dataO(j,:) = zscore(dataO(j,:));
%     end
   % ---------------------test for Q and R-----------------%%
    % No_SeqOS=1;
    %--------------------- Not test for Q and R-----------%%
     [No_SeqOS, lenS]=size(dataO);
    for SEQO=1:No_SeqOS
        Y=Distance_Computation(dataO(SEQO,:),TermSize);
        AS(SEQO,:)=Y.m;    AAS(SEQO,:)=Y.d;   AAAS(SEQO,:)=Y.sq;   AAAAS(SEQO,:)=Y.t;
    end
     xlswrite('SAXS85.xlsx', AS);  xlswrite('SEQS85.xlsx',AAS); xlswrite('BETAS85.xlsx',AAAS); xlswrite('SDS85.xlsx',AAAAS);
     str1111.m= xlsread('SAXS85.xlsx');
     str1111.d= xlsread('SEQS85.xlsx');
     str1111.sq= xlsread('BETAS85.xlsx');
     str1111.t= xlsread('SDS85.xlsx');  
end

for SEQO=1:No_SeqOS
    if dataO(SEQO,:) == str11
        Mean_Segment_Q=str1111.m(SEQO,:);
        Delta_Q= str1111.d(SEQO,:);
        SumSqr_deltaQ=str1111.sq(SEQO,:);
        TS_Q=str1111.t(SEQO,:);
    end
end

%Train=str_list1=S
[s_row,s_col]=size(str_list1);
L1=L-1; 
Rho_SQ=zeros(Terms,1);

for j=1:s_row
      Mean_Segment_S(j,:)=SDTT.m(j,:);
      Delta_S(j,:)=SDTT.d(j,:);
      SumSqr_deltaS(j,:)=SDTT.sq(j,:);
      TS_S(j,:)=SDTT.t(j,:); 
      for i=1:L1
            if(TS_Q(i)==TS_S(j,i))
                Corr_SQ(i)=1;
            else
                Corr_SQ(i)=-1;
            end
      end 
      for i=1:Terms-1
            Rho_SQ(i)=mean(Corr_SQ(segment(i):segment(i+1)-1));
      end
      Rho_SQ(Terms)=mean(Corr_SQ(segment(Terms):L1));
      TSim_SQ=zeros(Terms,1);
      for i=1:Terms
        TSim_SQ1=(SumSqr_deltaQ(i)-SumSqr_deltaS(j,i))^2;
        TSim_SQ2=2*SumSqr_deltaQ(i)*SumSqr_deltaS(j,i);
        TSim_SQ(i)=(1+Rho_SQ(i))*(TSim_SQ1/TSim_SQ2)+2;
      end
      DTrend1=zeros(Terms,1);
      DTrend2=zeros(Terms,1);
      DTrend3=zeros(Terms,1);
      DTrend4=zeros(Terms,1);
      %EU1=zeros(Terms,1);
      for  i=1:Terms-1
        DTrend1(i)=TermSize*(Mean_Segment_Q(i)-Mean_Segment_S(j,i))^2;
        DTrend2(i)=sum(Delta_Q(segment(i):segment(i+1)-1).^2);
        DTrend3(i)=sum(Delta_S(j,segment(i):segment(i+1)-1).^2);
        DTrend4(i)=TSim_SQ(i).*SumSqr_deltaQ(i).*SumSqr_deltaS(j,i);
      end

    DTrend1(Terms)=(L-segment(Terms)+1)*(Mean_Segment_Q(Terms)-Mean_Segment_S(j,Terms))^2;
    DTrend2(Terms)=sum(Delta_Q(segment(Terms):L).^2);
    DTrend3(Terms)=sum(Delta_S(j, segment(Terms):L).^2);
    DTrend4(Terms)=TSim_SQ(Terms).*SumSqr_deltaQ(Terms).*SumSqr_deltaS(j,Terms); 

    dist_arr(j)=sum(DTrend1)+sum(DTrend2)+sum(DTrend3)-sum(DTrend4);
 
end



%
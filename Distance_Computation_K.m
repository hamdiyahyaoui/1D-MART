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

function [DS]=Distance_Computation_K(S, Trend,TermSize)
L=length(S);
LT=length(Trend);
N_S=S;
Terms=ceil(LT/TermSize);
segment=1:TermSize:LT;
segmentT=1:TermSize:L;

Mean_Segments_S=zeros(Terms,1);
Delta_S=zeros(LT,1);
for i=1:Terms-1
        Mean_Segments_S(i)=mean(N_S(segment(i):segment(i+1)-1));
        Delta_S(segment(i):segment(i+1)-1)=Mean_Segments_S(i)-N_S(segment(i):segment(i+1)-1);
end
Mean_Segments_S(Terms)=mean(N_S(segment(Terms):LT));
Delta_S(segment(Terms):LT)=Mean_Segments_S(Terms)-N_S(segment(Terms):LT);
SumSqr_deltaS=zeros(Terms,1);
for i=1:Terms-1
       SumSqr_deltaS(i)=(sum(Delta_S(segment(i):segment(i+1)-1).^2)).^0.5;
end
SumSqr_deltaS(Terms)=(sum(Delta_S(segment(Terms):LT).^2)).^0.5;

%L1=L-1;   %length of Rho
TS_S=strings(LT,1);

 for i=1:Terms-1
        TS_S(i)=strcat(Trend{segment(i):segment(i+1)-1});
end

TS_S(Terms)=strcat(Trend{segment(i):segment(i+1)-1});

DS.m=Mean_Segments_S;
DS.d=Delta_S;
DS.sq=SumSqr_deltaS;
DS.t=TS_S;

end
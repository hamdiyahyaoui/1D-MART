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


function [DS]=Distance_Computation(S,TermSize)
L=length(S);
N_S=S;
Terms=ceil(L/TermSize);
segment=1:TermSize:L;

Mean_Segments_S=zeros(Terms,1);
Delta_S=zeros(L,1);
for i=1:Terms-1
        Mean_Segments_S(i)=mean(N_S(segment(i):segment(i+1)-1));
        Delta_S(segment(i):segment(i+1)-1)=Mean_Segments_S(i)-N_S(segment(i):segment(i+1)-1);
end
Mean_Segments_S(Terms)=mean(N_S(segment(Terms):L));
Delta_S(segment(Terms):L)=Mean_Segments_S(Terms)-N_S(segment(Terms):L);
SumSqr_deltaS=zeros(Terms,1);
for i=1:Terms-1
       SumSqr_deltaS(i)=(sum(Delta_S(segment(i):segment(i+1)-1).^2)).^0.5;
end
SumSqr_deltaS(Terms)=(sum(Delta_S(segment(Terms):L).^2)).^0.5;

L1=L-1;   %length of Rho
TS_S=strings(L1,1);

 for i=1:L1
     if(N_S(i+1)>N_S(i) || N_S(i+1)==N_S(i))
            TS_S(i)='101';
     else
            TS_S(i)='110';
     end
%end



DS.m=Mean_Segments_S;
DS.d=Delta_S;
DS.sq=SumSqr_deltaS;
DS.t=TS_S;

end
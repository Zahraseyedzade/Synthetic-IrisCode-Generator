%--------------------------------------------------------------------------
% CODE FOR READING IRISCODES AND MASKS. THIS EXAMPLE ONLY WORKS IF
% THE IRISCODES AND MASKS HAVE ALREADY BEEN CREATED AND CAN BE READ.
% ALL FILES ARE ASSUMED TO BE LOCATED IN THE CURRENT WORKING DIRECTORY.
% OTHERWISE, UPDATE THE PATHS AS SHOWN IN THE EXAMPLE BELOW:
%            fileID = fopen('c:\\Tmp\\IrisCode1_1.txt','r');
%
% AUTHOR:   ELECTRONIC ENGINEERING DEPARTMENT
%           UNIVERSITAT POLITÈCNICA DE CATALUNYA, 
%           08800, VILANOVA I LA GELTRÚ, SPAIN
%           (+34) 938967737
%
% THE CODE IS WRITTEN USING MATLAB R2019b VERSION
%--------------------------------------------------------------------------

close all;
clear all;

%--------------------------------------------------------------------------
% DECLARATION OF VARIABLES AND CONSTANTS.
%--------------------------------------------------------------------------
NUsers=500;
ImagesPerUser=10;
LENGTH=2048;
IrisCodes=ones(NUsers,LENGTH*ImagesPerUser);
Masks=ones(NUsers,LENGTH*ImagesPerUser);

%--------------------------------------------------------------------------
% READING FILES FOR IRISCODES AND MASKS.
%--------------------------------------------------------------------------
 for m=1:NUsers
     str1=strcat('IrisCode',num2str(m,3));
     str2=strcat('Mask',num2str(m,3));
     for n=1:ImagesPerUser
        strx=strcat('_',num2str(n,3));
        strIris=strcat(str1 , strx , ".txt");
        strMask=strcat(str2, strx, ".txt");
        fileID1 = fopen(strIris, 'r');  
        fileID2 = fopen(strMask, 'r');  
        formatSpec = '%d';
        IrisCodes(m,1+(n-1)*LENGTH:n*LENGTH)=(fscanf(fileID1,formatSpec))';
        Masks(m,1+(n-1)*LENGTH:n*LENGTH)=(fscanf(fileID2,formatSpec))';
        fclose(fileID1);
        fclose(fileID2);
     end
 end
 
%--------------------------------------------------------------------------
% HAMMING DISTANCE CALCULATION FOR IMPOSTORS USING MASKS.
%--------------------------------------------------------------------------
Count=1;
HD_Impostors=zeros(1,NUsers*(NUsers-1)/2);
for k1=1:(NUsers-1)
    for k2=k1+1:NUsers
        HD_Impostors(Count)=0;NMatch=0;
        for j=1:LENGTH
            if ((Masks(k1,j)==1 && Masks(k2,j)==1))
                NMatch= NMatch +1;                 
                if ((IrisCodes(k1,j)~=IrisCodes(k2,j)))
                    HD_Impostors(Count)= HD_Impostors(Count)+1;
                end 
            end
        end
        HD_Impostors(Count)=HD_Impostors(Count)/(NMatch);
        Count=Count+1;
    end
end

%--------------------------------------------------------------------------
% REPRESENTING THE IMPOSTOR STATISTIC USING MASKS.
% ADDITIONALLY, THE BINOMIAL DISTRIBUTION THAT MATCHES THIS STATISTIC IS
% ALREADY REPRESENTED.
%--------------------------------------------------------------------------

%Binomial distribution aproximation. 
pT=mean(HD_Impostors);
StdT=std(HD_Impostors,1);
NT=round((pT*(1-pT))/var(HD_Impostors,1));
LT=0:NT;
aT=binopdf(0:NT,NT,pT); 

TargetMean=0.5;
TargetStandardDeviation=0.0319;

%Printing results.
fprintf('\nIMPOSTOR STATISTICS WITH MASKS: \n');
fprintf('------------------------------------------------------------------- \n');
fprintf('                               REAL VALUE   THEORETICAL VALUE\n');
fprintf('Mean (probability):            %.3f        %.3f  (Err = %+.3f%%) \n', pT,TargetMean, 100*(pT-TargetMean)/TargetMean);
fprintf('Standard Deviation:            %.4f       %.4f (Err = %+.3f%%)  \n', StdT,TargetStandardDeviation, 100*(StdT-TargetStandardDeviation)/TargetStandardDeviation);
fprintf('------------------------------------------------------------------- \n');

%Histrogram calculation
NumBins=round(2.5*(max(HD_Impostors)-min(HD_Impostors))/StdT);
h=histogram(HD_Impostors,'NumBins',NumBins,'Normalization','probability');h.FaceColor=[0 1 0];
axis([0 1 0 1.25*max(h.Values)]);grid minor;

%Adding binomial distribution.
hold on;
plot(LT/NT,aT*(NT*h.BinWidth),'r','LineWidth',2);

%Labeling figure.
xlabel('Hamming distance');
ylabel('Probability');
legend('Histogram Impostors','Binomial');
str1=strcat('Mean = ',num2str(pT,3));
str2=strcat('Std.dev. = ',num2str(StdT,3));
str3=strcat('Max. HD = ',num2str(max(HD_Impostors),3));
str4=strcat('Min. HD = ',num2str(min(HD_Impostors),3));
str={str1, str2,str3,str4};
title('Hamming distance for impostors using Masks','Color','black');  
z=annotation('textbox', [.6 .5 .2 .2], 'String',str,'FitBoxToText','on');
z.FontSize=8;

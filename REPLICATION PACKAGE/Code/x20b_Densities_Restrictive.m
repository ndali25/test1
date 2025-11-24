function x20b_Densities_Restrictive(file, save_filename, save_sheetname)
% Code to replicate empirical results presented in:
%		Hounyo U. and Lahiri, K., (2021), Forthcoming, Journal of Money, Credit and Banking
%       "Are Some Forecasters Really Better Than Others? A Note"
% 
%  Ulrich Hounyo
%
%  April 10, 2020
%======================================================================
% x25_Densities_Restrictive.m
%======================================================================
% This program is mainly taken from the source cited above, with minor
% modifications made to work with this paper's data. This program produces
% the material for Table 4A.
%======================================================================

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING THE PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_path = '.\Data\Ready\';                % where the data spreadsheet is saved
save_path = '.\Output\HL Results\';         % change this to the directory to where you would like to save the results
save_name = '_densityscores_restricted';
save_sheetname_mod = strcat(save_sheetname, "_density_restricted");
rng('default')  % For reproducibility

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOADING IN THE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose the appropriate data
%RGDP
 data = xlsread([data_path, file]);
% data = xlsread([data_path,'RGDP_Error.xlsx'],'h=4','A2:EK109');
%Inflation
% data = xlsread([data_path,'PGDP_Error.xlsx'],'h=0','A2:FL109');
% data = xlsread([data_path,'PGDP_Error.xlsx'],'h=4','A2:EH109');

%%
%Set the number of bootstrap replications
bootreps=999;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data=transpose(data);
N=size(data,1);
T=size(data,2);
Ind_data=1-isnan(data);
n_It=sum(Ind_data);
n_Ti=sum(transpose(Ind_data));
N0=N;
n_It0=n_It;
n_Ti0=n_Ti;

for i=1:N
    for t=1:T        
        if Ind_data(i,t)==0
          data(i,t)=0;                        
        end
    end   
end
%%
%Begining of  Restrictive Data 1
comptdel=0;
for i=1:N0      
        if n_Ti(1,i)<20                      
          data(i-comptdel,:)=[];
          Ind_data(i-comptdel,:)=[];
          comptdel=comptdel+1;
        end   
end
N=size(data,1);
T=size(data,2);
n_It=sum(Ind_data);
n_Ti=sum(transpose(Ind_data));

%End of  Restrictive Data 1
%% 
%Begining of  Restrictive Data 2
% Compute normalized squared error
E2=data.^2;
E=zeros(N,T);
for i=1:N
    for t=1:T        
        if Ind_data(i,t)==1
          E(i,t)=E2(i,t)/((1/n_It(t))*sum(E2(:,t)));         
        end
    end   
end

Ind_data_raw=Ind_data;
E_abs=abs(data);        
S=nan(N,1);
for i=1:N
    S(i)=(1/n_Ti(i))*sum(E(i,:));                           %Score
end
Q80=quantile(S,0.80,1);
S1=S;
comptdel=0;
remove_ids = find(S>Q80);
for i=1:N      
        if S(i)>Q80
          data(i-comptdel,:)=[];
          Ind_data(i-comptdel,:)=[];
          comptdel=comptdel+1; 
        end  
end
N=size(data,1);
T=size(data,2);
n_It=sum(Ind_data);
n_Ti=sum(transpose(Ind_data));

%End of  Restrictive Data 2
%%
% Compute normalized squared error
E2=data;
E=zeros(N,T);
for i=1:N
    for t=1:T        
        if Ind_data(i,t)==1
          E(i,t)=E2(i,t)/((1/n_It(t))*sum(E2(:,t)));         
        end
    end   
end
S=nan(N,1);
for i=1:N
    S(i)=(1/n_Ti(i))*sum(E(i,:));                           %Score
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export scores combined with forecaster identifiers

id_extract(file, S, remove_ids, save_path, data_path, [save_sheetname save_name]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q=nan(6,1);
Q(1)=min(S);
Q(2)=quantile(S,0.05,1);
Q(3)=quantile(S,0.25,1);
Q(4)=quantile(S,0.50,1);
Q(5)=quantile(S,0.75,1);
Q(6)=max(S);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ve=nan(sum(n_It),1);
vE=nan(sum(n_It),1);
compt=0;
 
     for t=1:T 
        for i=1:N       
            if Ind_data(i,t)==1
                compt=compt+1;
                vE(compt,1)=E(i,t);    % vE is vec(E) without the missing values             
            end
        end 
        
     end    

%%%%%%          The bootstrap test of D'Agostino et al. (2012)
bootdates=nan(sum(n_It),bootreps);

     for t=1:T
         temp1=sum(n_It(1,1:t))-n_It(1,t)+1;
         temp2=sum(n_It(1,1:t));         
         bootdates(temp1:temp2,:) =STAT_MBB_function(n_It(t),bootreps,1); 
     end

     
%%%%%%          Cross-sectional and serial correlation bootstrap
Mat_external_rv_DWB=nan(T,bootreps);
 % choice of the block size using Andrews (1991) 
    % first obtain the score
     vecE=nan(sum(n_Ti),1);
     MvecE=nan(sum(n_Ti),1);
     compt=0;
     for i=1:N
        for t=1:T        
            if Ind_data(i,t)==1
                compt=compt+1;
                vecE(compt,1)=E(i,t);
                MvecE(compt,1)=S(i);                
            end
        end             
     end    
     %%% vecE is vec(of transpose of E) without the missing values 
     score= vecE-MvecE;
     [omega,lambda1,L] = lrcov(score,0,1,'A');
     l_T=ceil(L);       %   bandwidth choice
     %l_T=1; 
     %%%%
 % dependent wild bootstrap 
    BKernel=eye(T);
   for ii=1:T
       for jj=1:T
          % Bartlett kernel 
                if abs(jj-ii)<=l_T
                BKernel(ii,jj)=1-abs((jj-ii)/l_T);
                else
                BKernel(ii,jj)=0;
                end
       end  
   end
   % OUTPUTS:	 TxB matrix of external random variable eta for the DWB
   sqrt_BKernel=chol(BKernel);
   for bb=1:bootreps
       eta = exprnd(1,T,1);    %T i.i.d random variable from exponetial distribution with mean 1 and variance 1
       Mat_external_rv_DWB(:,bb)=sqrt_BKernel*eta;    
   end
bootQ=nan(6,bootreps);
npvalue_L=nan(6,bootreps);
npvalue_R=nan(6,bootreps);
npvalue_S=nan(6,bootreps);

bootQ_Agos=nan(6,bootreps);
npvalue_L_Agos=nan(6,bootreps);
npvalue_R_Agos=nan(6,bootreps);
npvalue_S_Agos=nan(6,bootreps);

%%%%%%%% Bootstrap replication starts
for bb=1:bootreps
    %%%%%%          Cross-sectional and serial correlation bootstrap
     bootE=zeros(N,T);
     %we resample the normalized squared error E 
  for i=1:N
    for t=1:T        
        if Ind_data(i,t)==1
          bootE(i,t)=E(i,t)*Mat_external_rv_DWB(t,bb);                     
        end
    end   
  end
  
bootS=nan(N,1);
for i=1:N
    bootS(i)=(1/n_Ti(i))*sum(bootE(i,:));                     
end
bootQ(1,bb)=min(bootS);
bootQ(2,bb)=quantile(bootS,0.05,1);
bootQ(3,bb)=quantile(bootS,0.25,1);
bootQ(4,bb)=quantile(bootS,0.50,1);
bootQ(5,bb)=quantile(bootS,0.75,1);
bootQ(6,bb)=max(bootS);

for i=1:6
    npvalue_L(i,bb)=bootQ(i,bb)<Q(i);
end

 bootE_Agos=zeros(N,T);
 bootvE_Agos=vE(bootdates(:,bb),1); 
 compt=0;
 
     for t=1:T 
         temp1=sum(n_It(1,1:t))-n_It(1,t)+1;
         temp2=sum(n_It(1,1:t));

        for i=1:N       
            if Ind_data(i,t)==1
                compt=compt+1;
                bootE_Agos(i,t)=bootvE_Agos(compt,1);
            end
        end 
     end 
     % compute the score Si
    bootS_Agos=nan(N,1);
for i=1:N
    bootS_Agos(i)=(1/n_Ti(i))*sum(bootE_Agos(i,:));                        
end
bootQ_Agos(1,bb)=min(bootS_Agos);
bootQ_Agos(2,bb)=quantile(bootS_Agos,0.05,1);
bootQ_Agos(3,bb)=quantile(bootS_Agos,0.25,1);
bootQ_Agos(4,bb)=quantile(bootS_Agos,0.50,1);
bootQ_Agos(5,bb)=quantile(bootS_Agos,0.75,1);
bootQ_Agos(6,bb)=max(bootS_Agos);

for i=1:6
    npvalue_L_Agos(i,bb)=bootQ_Agos(i,bb)<Q(i);
    npvalue_R_Agos(i,bb)=bootQ_Agos(i,bb)>Q(i);
    npvalue_S_Agos(i,bb)=abs(bootQ_Agos(i,bb))>abs(Q(i));
end

end    %End bootstrap replications

%          Cross-sectional and serial correlation bootstrap
bootQ5=nan(6,1);
bootQ95=nan(6,1);

for i=1:6
bootQ5(i)= quantile(bootQ(i,:),0.05,1);
end

for i=1:6
bootQ95(i)= quantile(bootQ(i,:),0.95,1);
end

%pvalue
pvalue_L=mean(npvalue_L, 2);
% Agostino et al. (2012)
bootQ5_Agos=nan(6,1);
bootQ95_Agos=nan(6,1);

for i=1:6
bootQ5_Agos(i)= quantile(bootQ_Agos(i,:),0.05,1);
end

for i=1:6
bootQ95_Agos(i)= quantile(bootQ_Agos(i,:),0.95,1);
end

%pvalue
pvalue_L_Agos=mean(npvalue_L_Agos, 2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % BASIC SUMMARY STATISTICS 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

table0 = nan(4,1);
table0(1,1)= N;
table0(2,1)= T;
T_bar=mean(n_Ti);
table0(3,1)= T_bar;
index_omega=N/(T_bar*(sum(1./n_Ti)));
table0(4,1)= index_omega;

info.fmt = '%10.3f';
info.cnames = strvcat('Stat');
info.rnames = strvcat('.','N','T','Tbar','index omega');
sprintf(['Table 0: Statistics'])
mprint(table0,info)
%---------------------------------------------------------------------------

table1a = nan(5,6);
for i=1:6
table1a(1,i)= Q(i);
table1a(2,i)= bootQ5_Agos(i);
table1a(3,i)= bootQ95_Agos(i);
table1a(4,i)= bootQ5(i,1);
table1a(5,i)= bootQ95(i,1);
end
cnames = ["Best"; "5"; "25"; "50"; "75"; "Worst"];
rnames = ["Score";"Agos-Q5th";"Agos-Q95th"; "New-Q5th"; "New-Q95th"];
title = "Table 1a: Distribution of Forecasting performance";
table1a = table_output(table1a, title, cnames, rnames, save_sheetname_mod, save_filename, 'overwritesheet');
disp(table1a)
%---------------------------------------------------------------------------

table2a = nan(2,6);
for i=1:6
table2a(1,i)= pvalue_L_Agos(i);
table2a(2,i)= pvalue_L(i);    
end
rnames = ["pvalue-L-Agos"; "pvalue-L"];
title = "Table 2a: Distribution of Forecasting performance: p-value";
table2a = table_output(table2a, title, cnames, rnames, save_sheetname_mod, save_filename, 'append');
disp(table2a)
%---------------------------------------------------------------------------
%---------------------------------------------------------------------------

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % THE END
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
function out1 = STAT_MBB_function(T,B,length)
%function out1 = STAT_MBB_function(T,B,length);
%
% This function generates bootstrap samples of the matrix data
% and returns the time indices for each sample
% Using the Overlapping Block Bootstrap (MBB) approach of Kunsch, H.R.(1989) "The jacknife and the bootstrap 
% for general stationary observations",The Annals of Statistics, 
% vol. 17, n. 3, p. 1217-1241.
% INPUTS:   T, a scalar, the number of time series observations to generate
%           B, a scalar, the number of bootstrap samples replication
%			length, a scalar, represent the block size to use for the MBB
%
% OUTPUTS:	out1, a TxB matrix of time indices for each bootstrap sample
%
%  Ulrich Hounyo
%
%  15 Feb 2019
% if nargin<4 || isempty(rand_state)
%     rng('shuffle');  
% else   
%     rng(rand_state); 
% end
% Number of blocks
k = fix(T/length);
%out1 = -999.99*ones(k*length,B);
out1 = -999.99*ones(T,B);

% BOOTSTRAPPING THE SAMPLE AND GENERATING THE BOOTSTRAP DIST'N OF THE THREE MEASURES
% Dimension of time series to be bootstrapped



% ------------------------------------------------------------
% INDEX SELECTION
% ------------------------------------------------------------


for bb = 1:B
    I = round(1+(T-length)*rand(1,k+1));
    %indB = [];
    for i=1:k
     %indB = [indB ; I(i):I(i)+length-1];
     out1((i-1)*length+1:i*length,bb)= I(i):I(i)+length-1;     
    end
   
    if T>k*length	
            out1(k*length+1:T,bb)=I(k+1):I(k+1)+T-k*length-1;     
    end

end
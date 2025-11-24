function [W, ts, cv5,cv10] = fn_kendall(X)
% Compute the Kendall's coefficient of concordance of the matrix X.
% Input:
%           X must be a n-by-m matrix, 
%           n: # of things being ranked (forecasters) 
%           m: # of rankers (variables) 
%           
%            
% Outputs:
%           W = Kendall's coefficient of concordance
%==========================================================================
% X1 = X(:,2:end);
X1 = X;
[n,m] = size(X1);
ranksum = sum(X1,2);
rbar = (m*(n+1))/2;
devs = ranksum-rbar;
sqdevs = devs.^2; 
S = sum(sqdevs,1); 
temp = n^3 - n;
W = 12*S/(m^2*temp);
% chi_squared = N*(K-1)*W;
ts = (12*S)/((m*n)*(n+1));
cv5 = chi2inv(0.95, n-1); 
cv10 = chi2inv(0.90, n-1); 
disp(n)
end
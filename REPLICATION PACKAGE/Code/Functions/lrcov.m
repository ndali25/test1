function [omega,lambda,L] = lrcov(x,pw,wght,mtd)
%In the context of linear regressions:

%Input:

% x:t*n. x=X*repmat(residual, 1,n) is the score matrix. 
%t is time dimension. n corresponds to the number of variables. In this case, X:T*n, residual:T*1.  

%pw: is 1 if the x is recentered/prewhitening. If else x is not recentered.

%wght: 0 if the first column of x corresponds to the intercept column, 1 if not

%If mtd=='A': Andrews automatic block length selection. If else Newey-West automatic block selection.
%Check Andrews (1991) for details on automatic block length selection
% Output:
% omega: Variance covariance estimator
% L: lenght of dependence/Used as bandwith with kernels

[t,n] = size(x);
wght = [wght;ones(n-1,1)];

% prewhitening

sigma = x'*x/t;

xt = x(2:t,:);
xl = x(1:t-1,:);

a = xt'*xl*inv(xl'*xl);

if pw ==1
    xpw = xt - xl*a';
else
    xpw = xt;
end

omega = xpw'*xpw/t;

%------------------
if mtd=='A'
    % Andrews
    xt = xpw(2:t-1,:);
    xl = xpw(1:t-2,:);
    b = diag((xt'*xl)./(xl'*xl));    
    Resid = xt-xl*diag(b);        
    s_resid = Resid'*Resid/t;
    s4 = diag(s_resid).^2;
    
    s_deux = (4* b.^2 .* s4 ./ ((1-b).^8));
    s_zero = ( s4 ./ ((1-b).^4)); 
    %delta = 1.3221*((wght'*(s_deux))/(wght'*(s_zero))).^(0.2); % this one is for Quadratic spectral kernel
    delta = 1.1447*((wght'*(s_deux))/(wght'*(s_zero))).^(0.2); % this one is for Bartlett kernel
    
else
    % Newey
    max = floor(4*((t/100)^(2/25)));
    s_deux = 0; 
    s_zero = 0;
    for j = 1:max 
        sig = wght'*((xpw(j+1:t-1,:)'*xpw(1:t-j-1,:))/t)*wght;
        s_deux = s_deux +2*j^2*sig;
        s_zero = s_zero +2*sig; 
    end
    sig0=wght'*omega*wght;
    s_zero = s_zero+sig0;
    %delta = 1.3221*((s_deux)./(s_zero)).^(0.4); % this one is for Quadratic spectral kernel
    delta = 1.1447*((s_deux)./(s_zero)).^(0.4); % this one is for Bartlett kernel
       
end
%---------------
L = delta*t^(0.2);

lambda = 0;
for j=1:t-2
    gamma = xpw(j+1:t-1,:)'*xpw(1:t-j-1,:)/t;
    v=j/L;
    w=6*pi*v/5;        
    qs=((25./(12*((pi*v).^2))).*(((sin(w))./w)-cos(w)));
    omega = omega + qs*(gamma + gamma');
    lambda = lambda +qs*gamma;
    
end

% recolor if prewhitening

if pw ==1
    dinv = inv(eye(n)-a);
    omega = dinv*omega*dinv';
    lambda = dinv*lambda*dinv' + sigma*a'*dinv';
end
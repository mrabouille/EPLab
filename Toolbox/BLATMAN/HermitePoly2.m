
% HermitePoly.m by David Terr, Raytheon, 5-10-04

% Given nonnegative integer n, compute the 
% Hermite polynomial H_n. Return the result as a vector whose mth
% element is the coefficient of x^(n+1-m).
% polyval(HermitePoly(n),x) evaluates H_n(x).


function hk = HermitePoly2(n,choise)
if nargin==2 && ~choise
    % for the 'physicists' Hermite polynomials
    c=2;
else
    % for 'probabilists' Hermite polynomials
    c=1;
end

if n==0 
    hk = 1;
elseif n==1
    hk = [c 0];
else
    
    hkm2 = zeros(1,n+1);
    hkm2(n+1) = 1;
    hkm1 = zeros(1,n+1);
    hkm1(n) = c;

    for k=2:n
        
        hk = zeros(1,n+1);

        for e=n-k+1:2:n
            hk(e) = c*(hkm1(e+1) - (k-1)*hkm2(e));
        end
        
        hk(n+1) = -c*(k-1)*hkm2(n+1);
        
        if k<n
            hkm2 = hkm1;
            hkm1 = hk;
        end
        
    end
    
end
function  p = pnorm(x,m,s)
%PNORM 	  The normal distribution function
%
%   p = pnorm(x,m,s)
%         
%	Input	x	real
%	  	m	mean (default value is 0)
%		s 	standard deviation (default value is 1)
%               (x,m,s can be scalar or matrix with common size)
%	Output	p	normal density function with mean m and standard 
%			deviation s, at the value of x :
%			 y=integral form -inf to x of
%			exp(-0.5*((t-m)./s)^2)./sqrt(2*pi*s)dt

%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg

%	Revision 31-10-98 Mathematique Universite de Paris-Sud

if nargin<3, s=1; end
if nargin<2, m=0; end
p= 0.5 + erf((x-m)./(sqrt(2).*s))/(2);
%p= (1+erf((x-m)./(sqrt(2).*s)))/2;

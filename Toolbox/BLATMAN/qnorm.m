function  x = qnorm(p,m,s)
%QNORM 	  The normal inverse distribution function
%
%   q = qnorm(p,m,s)
%         
%	Input	p	probability
%		 	m	mean (default value is 0)
%			s 	standard deviation (default value is 1)
%			(q,m,s can be scalar or matrix with common size)
%	Output  q  	real such that Prob(X<=q)=p where X is a 
%				normal variable with mean m and standard
%				deviation s

%       Anders Holtsberg, 13-05-94
%       Copyright (c) Anders Holtsberg

%	Revision 31-10-98 Mathematique Universite de Paris-Sud

if nargin<3, s=1; end
if nargin<2, m=0; end

if any(any(abs(2*p-1)>1))
   error('A probability should be 0<=p<=1, please!')
end
if any(any(s<=0))
   error('Parameter s is wrong')
end

x = erfinv(2*p-1).*sqrt(2).*s + m;


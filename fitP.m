function P=fitP(p,T)
%expression used to automatically fit P(Tbath) data.

[ii,jj]=size(T);
model=ii;
if model==1
    %%%p(1)=a=-K, p(2)=n, p(3)=P0=K*Tc^n
    P=p(1)*T.^p(2)+p(3);
elseif model==2
    %%%p(1)=-K, p(2)=n, p(3)=P0=K*Tc^n, p(4)=Ic0. p(5)=Pnoise
    P=p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3)+p(5);
elseif model>2
    error('wrong P(T) model?')
end
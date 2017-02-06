function P=fitP(p,T)
%expression used to automatically fit P(Tbath) data.

model=2;
if model==1
    %%%p(1)=a=-K, p(2)=n, p(3)=P0=K*Tc^n
    P=p(1)*T.^p(2)+p(3);
elseif model==2
    %%%p(1)=-K, p(2)=n, p(3)=P0=K*Tc^n, p(4)=Ic0.
    P=p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3);
end
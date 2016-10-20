function P=fitP(p,T)
%expression used to automatically fit P(Tbath) data.
P=p(1)*T.^p(2)+p(3);
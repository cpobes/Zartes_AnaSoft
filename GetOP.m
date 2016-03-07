function OP=GetOP(Tbath,Ib,IV,TES,varargin)
% funcion para definir el punto de operacion completo de un TES a partir de la Tbath, Ib y la
% curva IV correspondiente.

if nargin>4
    Circuit=varargin{1}
else
    Circuit.Rf=1e3;
end

ibias=Ib;
ind=abs(IV(:,1)-ibias)<1e-10
vout=IV(ind,2);
[ites,vtes,ptes,rtes]=GetIVTES(vout,ibias,Circuit.Rf);
OP.I0=ites;
OP.V0=vtes;
OP.P0=ptes;
OP.rp=rtes;
OP.R0=rtes*TES.Rn;
ttes=(ptes/TES.K+Tbath^TES.n).^(1/TES.n);
OP.T0=ttes;
OP.Tbath=Tbath;
OP.Ib=Ib;
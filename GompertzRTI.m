function Rtes=GompertzRTI(Ttes,Ites,varargin)
%%%Intento de usar gompertz para representar la R(T,I)

if nargin==2
    Tc0=0.0927;
    Ic0=1e-1;
else
    TES=varargin{1};
    Tc0=TES.Tc0;
    Ic0=TES.Ic0;
end

%a=0.04;b=0.01;c=0.01;d=1.5e-3;e=1e-4;
a=87.2e-3; b=1e-2;c=0;
d=4e-3;e=1e-3;

Tc=@(I)Tc0*(1-(I/Ic0).^(2/3));
plane=@(T,I)(a+b*T+c*I);
den=@(I)(d+e*I);
Rtes=plane(Ttes,Ites).*(0.5).^exp(-(Ttes-Tc(Ites))./(den(Ites)));
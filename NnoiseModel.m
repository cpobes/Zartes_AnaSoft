function N=NnoiseModel(circuit, Tbath, varargin)
%%%Función para devolver el modelo de ruido total en estado normal o
%%%superconductor

Kb=1.38e-23;

invMin=circuit.invMin;
invMf=circuit.invMf;
Rf=circuit.Rf;
RL=circuit.Rsh+circuit.Rpar;
RN=circuit.Rn;

if isfield(circuit,'squid')
    i_squid=circuit.squid;
else
    i_squid=3e-12;
end

tau=circuit.L/(RL+RN);
f=logspace(0,6,1000);
w=2*pi*f;

Rtes=RN;
if nargin==3 
    Ttes=varargin{1};
else
    Ttes=Tbath;
end 
%Ttes=max(Tbath,Tc);

Zcirc=RL+Rtes+1i*w*circuit.L;% impedancia del circuito.
v2_sh=4*Kb*Tbath*RL; % ruido voltaje Rsh (mas parasita).
v2_tes=4*Kb*Ttes*Rtes;%ruido voltaje en el TES en estado normal.
i_jo=sqrt(v2_sh+v2_tes)./abs(Zcirc);
%%i_jo=sqrt(4*Kb*Tbath/(RTES))./sqrt(1+(tau*w).^2);%%%06-04-20.no elevaba al cuadrado tau*w!!!
%i_jo=sqrt(4*Kb*Tbath/(RTES))./(1+tau*w);
%[sqrt(4*Kb*Tbath/RL) sqrt(4*Kb*Tbath/RN) sqrt(4*Kb*Tbath/RTES)]
%N=sqrt(i_sh.^2+i_jo.^2+i_squid^2);
N=sqrt(i_jo.^2+i_squid^2);
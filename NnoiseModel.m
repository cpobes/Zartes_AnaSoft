function N=NnoiseModel(circuit, Tbath)
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
f=logspace(0,6);
w=2*pi*f;
%(Rf*invMf/invMin)*
%i_sh=sqrt(4*Kb*Tbath/RL)./(1+tau*w);
RTES=RN+RL;
i_jo=sqrt(4*Kb*Tbath/(RTES))./(1+tau*w);
%[sqrt(4*Kb*Tbath/RL) sqrt(4*Kb*Tbath/RN) sqrt(4*Kb*Tbath/RTES)]
%N=sqrt(i_sh.^2+i_jo.^2+i_squid^2);
N=sqrt(i_jo.^2+i_squid^2);
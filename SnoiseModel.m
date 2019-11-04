function N=SnoiseModel(circuit, Tbath)
%%%Función para devolver el modelo de ruido total en estado normal o
%%%superconductor en unidades de A/sqrt(Hz).
Kb=1.38e-23;

invMin=circuit.invMin;
invMf=circuit.invMf;
Rf=circuit.Rf;
RL=circuit.Rsh+circuit.Rpar;

if isfield(circuit,'squid')
    i_squid=circuit.squid;
else
    i_squid=3e-12;
end

tau=circuit.L/RL;
f=logspace(0,6);
w=2*pi*f;
%(Rf*invMf/invMin) factor para convertir en Voltaje.
i_sh=sqrt(4*Kb*Tbath/RL)./(1+tau*w);

N=sqrt(i_sh.^2+i_squid^2);
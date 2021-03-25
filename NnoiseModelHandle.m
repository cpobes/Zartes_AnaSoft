function NoiseHandle=NnoiseModelHandle(circuit,Tbath,varargin)
%%%Función para devolver el modelo de ruido total en estado normal
%%% como un handle.

Kb=1.38e-23;

invMin=circuit.invMin;
invMf=circuit.invMf;
Rf=circuit.Rf;
RL=circuit.Rsh+circuit.Rpar;
RN=circuit.Rn;

if nargin==3 
    Ttes=varargin{1};
else
    Ttes=Tbath;
end 

if isfield(circuit,'squid')
    i_squid=circuit.squid;
else
    i_squid=3e-12;
end

Rtes=RN;

Zcirc=@(f) RL+Rtes+1i*2*pi*f*circuit.L;% impedancia del circuito.
v2_sh=4*Kb*Tbath*RL; % ruido voltaje Rsh (mas parasita).
v2_tes=4*Kb*Ttes*Rtes;%ruido voltaje en el TES en estado normal.

i_jo=@(f) sqrt(v2_sh+v2_tes)./abs(Zcirc(f));
NoiseHandle=@(f) sqrt(i_jo(f).^2+i_squid^2);

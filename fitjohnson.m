function NEP=fitjohnson(M,f,PARAMETERS)
%%%%Funci�n para ajustar simult�neamente el ruido NEP experimental
%%%%expresado en attoW con la Mph y la Mjo al modelo de Irwin!
%%%%Ojo porque para sacar el NEP necesitamos la sI, que se saca del modelo,
%%%%as� que para cada modelo hay que pasarle el modelo correcto a
%%%%noisesim.

Kb=1.38e-23;

OP=PARAMETERS.OP;
Circuit=PARAMETERS.circuit;
TES=PARAMETERS.TES;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
G=TES.G;
T0=TES.Tc;
Rn=TES.Rn;
n=TES.n;

Rs=Circuit.Rsh;
Rpar=Circuit.Rpar;
L=Circuit.L;

alfa=OP.ai;
bI=OP.bi;
RL=Rs+Rpar;
R0=OP.R0;
beta=(R0-Rs)/(R0+Rs);
%T0=OP.T0;
Ts=OP.Tbath;
P0=OP.P0;
T0=TES.Ttes(P0,Ts);%%%Recalculamos T0 ya que los par�metros se calculan tambi�n con esa Ttes.
G=TES.Gtes(T0);%%%Recalculamoss G0 ya que los par�metros se calculan tambi�n con esa Gtes.
I0=OP.I0;
V0=OP.V0;
%L0=P0*alfa/(G*T0);
L0=OP.L0;%%%L0 debe estar tambi�n en los par�metros del OP.
C=OP.C;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tau=C/G;
taueff=tau/(1+beta*L0);
tauI=tau/(1-L0);
tau_el=L/(RL+R0*(1+bI));

t=Ts/T0;
F=(t^(n+2)+1)/2;%%%specular limit

M=real(M);%forzamos valores reales.

sI=-(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;
stfn=4*Kb*T0^2*G*abs(sI).^2*F*(1+M(1)^2);
stes=4*Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M(2)^2);
ssh=4*Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
NEP=1e18*sqrt(stes+stfn+ssh)./abs(sI);
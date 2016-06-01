function noise=noisesim(model,varargin)
%simulacion de componentes de ruido.
%de donde salen las distintas componentes de la fig13.24 de la pag.201 de
%la tesis de maria? ahi estan dadas en pA/rhz.
%Las ecs 2.31-2.33 de la tesis de Wouter dan nep(f) pero no tienen la
%dependencia con la freq adecuada. Cuadra más con las ecuaciones 2.25-2.27
%que de hecho son ruido en corriente.
%La tesis de Maria hce referencia (p199) al capítulo de Irwin y Hilton
%sobre TES en el libro Cryogenic Particle detection. Tanto en ese capítulo
%como en el Ch1 de McCammon salen expresiones para las distintas
%componentes de ruido. 

%definimos unos valores razonables para los parámetros del sistema e
%intentamos aplicar las expresiones de las distintas referencias.

gamma=0.5;
Kb=1.38e-23;

if nargin==1
C=2.3e-15;%p220
L=77e-9;%400e-9;%inductancia. arbitrario.
G=310e-12;%1.7e-12;% p220 maria.
alfa=1;%arbitrario.
bI=0.96;%p220
Rn=15e-3;%32.7e-3;%p220.
Rs=2e-3;%Rshunt.
Rpar=0.12e-3;%0.11e-3;%R parasita.
RL=Rs+Rpar;
R0=0.00000001*Rn;%pto. operacion.
R0=0.5*Rn;
beta=(R0-Rs)/(R0+Rs);
T0=0.06;%0.42;%0.07
Ts=0.06;%0.20;
%P0=77e-15;
%I0=(P0/R0)^.5;
I0=50e-6;%1uA. deducido de valores de p220.
V0=I0*R0;%
P0=I0*V0;
L0=P0*alfa/(G*T0);
else
    TES=varargin{1};
    OP=varargin{2};
    Circuit=varargin{3};
    C=TES.OP.C;
    L=Circuit.L;
    G=TES.G;
    alfa=TES.OP.ai;
    bI=TES.OP.bi;
    Rn=TES.Rn;
    Rs=Circuit.Rsh;
    Rpar=Circuit.Rpar;
    RL=Rs+Rpar;
    R0=OP.R0;
    beta=(R0-Rs)/(R0+Rs);
    T0=OP.T0;
    Ts=OP.Tbath
    P0=OP.P0;
    I0=OP.I0;
    V0=OP.V0;
    L0=P0*alfa/(G*T0);
end

tau=C/G;
taueff=tau/(1+beta*L0);
tauI=tau/(1-L0);
tau_el=L/(RL+R0*(1+bI));

%f=1:1e6;
f=logspace(0,6);
if strcmp(model,'wouter')
%%%ecuaciones 2.25-2.27 Tesis de Wouter.
i_ph=sqrt(4*gamma*Kb*T0^2*G)*alfa*I0*R0./(G*T0*(R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
i_jo=sqrt(4*Kb*T0*R0)*sqrt(1+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
i_sh=sqrt(4*Kb*Ts*Rs)*sqrt((1-L0)^2+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));%%%
noise.ph=i_ph;noise.jo=i_jo;noise.sh=i_sh;noise.sum=i_ph+i_jo+i_sh;

elseif strcmp(model,'irwin') 
%%% ecuaciones capitulo Irwin

sI=-(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;%funcion de transferencia.
t=Ts/T0;
n=3.5;
F=t^(n+1)*(t^(n+2)+1)/2;%F de boyle y rogers. n= exponente de la ley de P(T). El primer factor viene de la pag22 del cap de Irwin.
%F=t^(n+1)*(n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%F de Mather.
stfn=4*Kb*T0^2*G*abs(sI).^2*F;%Thermal Fluctuation Noise
ssh=4*Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
stes=4*Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2;

i_ph=sqrt(stfn);
i_jo=sqrt(stes);
i_sh=sqrt(ssh);
noise.ph=i_ph;noise.jo=i_jo;noise.sh=i_sh;noise.sum=sqrt(stfn+stes+ssh);%noise.sum=i_ph+i_jo+i_sh;
else
    error('no valid model')
end
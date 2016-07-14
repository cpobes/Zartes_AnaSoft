function param=GetModelParameters(p,IVmeasure,Ib,TES,Circuit)
%extrae los parámetros térmicos del sistema a partir de un modelo térmico y
%conociendo el punto de operación y la 'G'

%known parameters
%R0=210e-3;%79e-3;
%P0=80e-15;%77e-15;
%I0=(P0/R0)^.5;
%G=1.66e-12;%1.7e-12;
%T0=0.155;%;0.07;
%global R0 P0 I0 T0 G C ai bi

Rn=TES.Rn;
T0=TES.Tc;
G0=TES.G0;
pp=spline(IVmeasure.ibias,IVmeasure.vout);%%ojo, el spline no es bueno fuera de la transición.
Vout=ppval(pp,Ib);
%ind=find(abs(IVmeasure.ib-Ib)<1e-10);
%Vout=IVmeasure.vout(ind);
%[I0,V0]=GetIVTES(Vout,Ib,Rf);
IVaux.ibias=Ib;
IVaux.vout=Vout;
IVaux.Tbath=IVmeasure.Tbath;
IVstruct=GetIVTES(Circuit,IVaux);%%%

I0=IVstruct.ites;
V0=IVstruct.vtes;
%Rn=25.0e-3;
%R0=0.46*Rn;%0.0147;
%T0=145e-3;
%V0=0.507e-6;I0=43.78e-6;
P0=V0.*I0;
%G=716e-12;
R0=V0/I0;
R0/Rn

%derived parameters
%for simple model p(1)=Zinf, p(2)=Z0, p(3)=taueff
%rp=real(p);
rp=p;
param.bi=(rp(1)/R0)-1;
param.L0=(rp(2)-rp(1))/(rp(2)+R0);
param.tau0=rp(3)*(param.L0-1);
param.C=param.tau0*G0;
param.ai=param.L0*G0*T0/P0;
param.rp=R0/Rn;
param.Zinf=rp(1);
param.Z0=rp(2);
param.taueff=rp(3);


function TF=BuildLinearModel()
%%%creamos un modelo matlab con las ecuaciones linealizadas de los TES.
%%set1:G=1.7e-12;C=2.3e-15;I0=1e-6;L=400e-9;R0=80e-3;T0=.150;alfa=100;bi=0.96;
%parametros

%P0=77e-15;%80e-15;%77e-15; % potencia disipada en equilibrio
Rsh=2e-3;Rpar=0.31e-3;
R0=15e-3;%210e-3;%79e-3; % R de equilibrio
I0=1e-6;
P0=I0^2*R0;
%I0=(P0/R0)^.5; % corriente de equilibrio
T0= 0.41;%0.07; %pto. operacion.aprox Tc.(0.155)
%G=1.7e-12;%1.66e-12;%1.7e-12; %conductancia termica con el baño
G=1.7e-12;C=2.3e-15;
L=400e-9;

%sim param
%C=2.3e-15;%3e-15;%2.3e-15; % capacidad termica del TES
%C=1.8e-14;
ai=100;%100;%131; % sensibilidad logaritmica de R vs T.
bi=0.96;%1;%0.96; % parametro entre 0 y 1. sensibilidad logaritmica de R vs I.

%deduced param
L0=P0*ai/(G*T0); % low freq loop gain.
%tau=1/(I0^2*R0*ai/(C*T)-G/C) %constante de tiempo efectiva

tau0=C/G;
tau_i=tau0/(L0-1);
tau_el=L/(Rsh+Rpar+R0*(1+bi));

%-A.ojo a los signos. ec(19)Irwin.Tb Ch4 tesis lindeman.
A(1,1)=-1/tau_el;
A(1,2)=-L0*G/(I0*L);
A(2,1)=I0*R0*(2+bi)/C;
A(2,2)=1/tau_i;

tauetc=sqrt(abs(A(1,2)*A(2,1)))^-1;
%tau_el,tau_i,
%sqrt(tau_el*tau_i),1/(1/tau_el+1/tau_i)

%%%system definition.%%% 3 equivalent methods.
%por bloques.
%tf1=tf({1 0;0 1},{[1 0] 1;1 [1 0]});%I*1/s
%%%%tf2=tf({A(1,1) A(1,2);A(2,1) A(2,2)},1);
%TF=feedback(tf1,A);

%direct
%%%den=[1 A(1,1)+A(2,2) A(1,1)*A(2,2)-A(1,2)*A(2,1)];%use det(A),tr(A)
%den=[1 trace(A) det(A)];
%TF=tf({[1 A(2,2)] -A(1,2);-A(2,1) [1 A(1,1)]},den)

%matrix algebra
s=tf('s');
TF=1/(s*eye(2)-A);
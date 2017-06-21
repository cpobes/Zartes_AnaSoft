function plotGeneralParam(P,varargin)
%%%Función para pintar y formatear parámetros a partir de una estructura P.

%xl='ai';
%yl='M';

if nargin>1
    opt=varargin{1};
    optname=[opt.name];
    optvalue=[opt.value];
else
    optname={'markersize'}
    optvalue={15}
end

indx=[1:length(P)];
%indx=13;
for i=indx%length(P),
    %x=eval(strcat('[','P(i).p.',xl,']'));
    %y=eval(strcat('[','P(i).p.',yl,']'));
    ALL=GetAllPparam(P(i));
    %%%%%expand parameters
    rp=ALL.rp;L0=ALL.L0;ai=ALL.ai;bi=ALL.bi;tau0=ALL.tau0;taueff=ALL.taueff;C=ALL.C;Zinf=ALL.Zinf;Z0=ALL.Z0;ExRes=ALL.ExRes;ThRes=ALL.ThRes;M=ALL.M;Mph=ALL.Mph;
    Tb=ALL.Tb;
    %%ecX='ai./sqrt(1+2*bi)';%%%Ecuacion para la X
    %%ecX='ai./bi';
    %%%ecX='ai./L0-1';
    %%%ecX='(1+2*bi)';    
    ecX='rp';
    %ecX='Tb';
    
    x=eval(ecX);
    ecY='Mph';%%%Ecuacion para la Y
    %ecY='abs(tau0)';
    %ecY='ai./L0-1';
    %ecY='ai./(1+bi)';%%alfa_eff_Aprox
    %ecY='ai.*(2*L0+bi)./(2+bi)./L0';%%%alfa_eff1
    RL=2.028e-3;
    Rn=23.2e-3;
    %ecY='ai./(1+bi./(1+RL./(rp*Rn)))';%%%alfa_eff2
    %ecY='tau0./(1+L0.*(1-RL./(rp*Rn))./(1+bi+RL./(rp*Rn)))';
    ecY='taueff';
    y=eval(ecY);
    h=plot(x,y,'.r-');hold on
    set(h,optname,optvalue);
end

hold off,
grid on
xlabel(ecX,'fontsize',12);
ylabel(ecY,'fontsize',12);
set(gca,'linewidth',2,'fontsize',12);
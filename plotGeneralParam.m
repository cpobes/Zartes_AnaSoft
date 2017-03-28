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
    rp=ALL.rp;L0=ALL.L0;ai=ALL.ai;bi=ALL.bi;tau0=ALL.tau0;taueff=ALL.taueff;C=ALL.C;Zinf=ALL.Zinf;Z0=ALL.Z0;ExRes=ALL.ExRes;ThRes=ALL.ThRes;M=ALL.M;
    
    %%ecX='ai./sqrt(1+2*bi)';%%%Ecuacion para la X
    %%ecX='ai./bi';
    %%%ecX='ai./L0-1';
    ecX='rp';    
    x=eval(ecX);
    ecY='M';%%%Ecuacion para la Y
    %ecY='ai./L0-1';
    y=eval(ecY);
    h=plot(x,y,'.');hold on
    set(h,optname,optvalue);
end

hold off,
grid on
xlabel(ecX,'fontsize',12);
ylabel(ecY,'fontsize',12);
set(gca,'linewidth',2,'fontsize',12);
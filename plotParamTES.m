function plotParamTES(P,xl,yl,varargin)
%%%Función para pintar y formatear parámetros a partir de una estructura P.
%%%% Pinta parametro x frente a y a todas las temperaturas para un TES
%%%% dado.

%xl='ai';
%yl='M';

if nargin>3
    opt=varargin{1};
    optname=[opt.name,{'markersize'}]
    optvalue=[opt.value,{15}]
else
    optname={'markersize','linestyle'}
    optvalue={15,'-'}
end

for i=1:length(P),
    %x=eval(strcat('[','P(i).p.',xl,']'));
    %y=eval(strcat('[','P(i).p.',yl,']'));
    x=GetPparam(P(i).p,xl);
    y=GetPparam(P(i).p,yl);
    h=plot(x,y,'.r');hold on
    set(h,optname,optvalue);
end

%hold off,grid on
grid on
xlabel(xl,'fontsize',12,'fontweight','bold');
ylabel(yl,'fontsize',12,'fontweight','bold');
set(gca,'linewidth',2,'fontsize',12,'fontweight','bold');
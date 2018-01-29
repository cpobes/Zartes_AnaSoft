function plotParam(P,xl,yl,varargin)
%%%Función para pintar y formatear parámetros a partir de una estructura P.

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
xlabel(xl,'fontsize',12);
ylabel(yl,'fontsize',12);
set(gca,'linewidth',2,'fontsize',12);
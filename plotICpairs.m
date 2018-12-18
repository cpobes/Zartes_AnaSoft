function plotICpairs(varargin)
%%%%Funcion para pintar el escaneo en campo a partir de los ficheros
%%%%ICpairs

if nargin==0
    faux=ls('ICpairs*');
else
    faux=varargin{1};
end

colores=evalin('caller','colores');%%%%ojo, hay que cargar colores antes.
fc=fieldnames(colores);
hold off

fcal=4600;%%%muT por Amperio.

for i=1:length(faux(:,1))
    load(faux(i,:));
    x=regexp(faux(i,:),'ICpairs(?<temp>\d*(.\d+)?mK)','names');
    temps{i}=x.temp;
    plot([ICpairs.B]*fcal,[ICpairs.p],'o-','color',colores.(fc{i}),'linewidth',1,'markerfacecolor','auto');hold on %%%valido solo para 7 curvas.
    plot([ICpairs.B]*fcal,[ICpairs.n],'o-','color',colores.(fc{i}),'linewidth',1,'markerfacecolor','auto');
    %{faux(i,:)  fc{i}}
end

h=get(gca,'children');
legend(h(end:-2:2),temps);
axis tight
set(gca,'fontsize',20,'fontweight','bold')
xlabel('B_{field}(\muT)')
ylabel('I_{critica}(\muA)')
grid on
    
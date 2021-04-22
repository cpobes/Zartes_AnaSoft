function indx=GetIndexInWindow()
%%%Funci�n para extraer autom�ticamente los �ndices de poblaciones en un
%%%scatter a partir de lo que se est� mostrando en la figura actual. Ojo,
%%%s�lo funciona con un �nico objeto-plot en la figura.
xlims=get(gca,'Xlim');
ylims=get(gca,'Ylim');

scatt=get(gca,'Children');
xdata=get(scatt,'XData');
ydata=get(scatt,'YData');

indx=find(xdata>xlims(1) & xdata<xlims(2) & ydata>ylims(1) & ydata<ylims(2));
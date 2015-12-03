function buildIVfullset(h)
%funcion para pintar todo un set de parametros de IVs a partir de los datos
%de una grafica medida. Sirve para poder pintar de golpe todos los datos
%Vout-Ibias y poder eliminar curvas 'malas' a mano y a partir del handle de
%esa grafica sacar las curvas del TES automaticamente.

%h=get(f,'children');

%parametros
Rf=1e3;
Rpar=0.31e-3;
Rsh=2e-3;
Rn=35.8e-3;

figure
subplot(2,2,1)
for i=1:length(h)
    subplot(2,2,1)
    x=get(h(i),'xdata');
    y=get(h(i),'ydata');
    plot(x,y,'.-'),hold on
    ites=y*22/(66*Rf);
    vtes=(x-ites)*Rsh-ites*Rpar;
    ptes=vtes.*ites;
    Rtes=vtes./ites;
    rtes=Rtes/Rn;
    subplot(2,2,2),plot(vtes,ites,'.-'),hold on;
    subplot(2,2,3),plot(vtes,ptes,'.-'),hold on;
    subplot(2,2,4),plot(rtes,ptes,'.-'),hold on;
end  
subplot(2,2,1),title('Vout vs Ibias'),xlabel('Ibias'),ylabel('Vout'),grid on
subplot(2,2,2),title('Ites vs Vtes'),xlabel('Vtes'),ylabel('Ites'),grid on
subplot(2,2,3),title('Ptes vs Vtes'),xlabel('Vtes'),ylabel('Ptes'),grid on
subplot(2,2,4),title('Ptes vs r%'),xlabel('r%'),ylabel('Ptes'),grid on

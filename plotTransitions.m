function varargout=plotTransitions(T,R1,R2,ind)
%version preliminar para pintar transiciones. Puede hacer falta pasar
%indices separados para cada canal y generalizar a varios ficheros. Tambien
%añadir el fit.

plot(T(ind),R1(ind),'.')
hold on
plot(T(ind),R2(ind),'r.')
h=get(gca,'children');
set(h(1),'MarkerSize',15)
set(h(2),'MarkerSize',15)
grid on
legend('R1','R2')
xlabel('T(K)')
ylabel('R(\Omega)')

%primera version para incluir tambien fit. De momento requiere poner
%manualmente los p0 y solo sirve para 2 CH.
fit=1;
if fit
    %p01=[0.1 0.98 0.01 3 0.98 0.01];
p01=[0.1 0.82 0.01];
    %p02=[0.1 0.99 0.01 3 1.0 0.01];
p02=[0.1 0.86 0.01];
    
    [p1,aux1,aux2,aux3,out]=lsqcurvefit(@fitTc,p01,T(ind),R1(ind));
    [p2,aux1,aux2,aux3,out]=lsqcurvefit(@fitTc,p02,T(ind),R2(ind));
    plot(T(ind),fitTc(p1,T(ind)),'b');
    plot(T(ind),fitTc(p2,T(ind)),'r');
    legend('R1','R2','fit R1','fit R2')
    varargout{1}=p1;
    varargout{2}=p2;
end
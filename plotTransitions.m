function varargout=plotTransitions(varargin) %T,R1,R2,ind
%version preliminar para pintar transiciones. Puede hacer falta pasar
%indices separados para cada canal y generalizar a varios ficheros. Tambien
%añadir el fit.

if nargin==0
    [~,data]=loadppms();
    T=data.T;R1=data.R1;R2=data.R2;ind=1:length(data.T);
    fit=0;
    hold off;
else
    T=varargin{1};R1=varargin{2};R2=varargin{3};ind=varargin{4};
    fit=1;
end

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

if fit
    %definición manual de p0. Va mal con 'ere'.Mejorar.
   % p01=[0.1 0.89 0.01 1.7 0.9 0.01];
    p01=[1.0 0.96 0.01];
    %p02=[0.1 0.96 0.01 1.1 0.97 0.01];
    p02=[1.1 0.96 0.01];
    
    [p1,aux1,aux2,aux3,out]=lsqcurvefit(@fitTc,p01,T(ind),R1(ind));
    [p2,aux1,aux2,aux3,out]=lsqcurvefit(@fitTc,p02,T(ind),R2(ind));
    plot(T(ind),fitTc(p1,T(ind)),'b');
    plot(T(ind),fitTc(p2,T(ind)),'r');
    legend('R1','R2','fit R1','fit R2')
    varargout{1}=p1;
    varargout{2}=p2;
end
function plotIVs(Circuit,IVmeasure)
%Versión para usar como parámetros de entradauna estructura IVmeasure con
%toda la información necesaria.

IVstruct=GetIVTES(Circuit,IVmeasure);

% plot(vtes,ites,'.--'),grid on,hold on
% xlabel('Vtes(V)');ylabel('Ites(A)');

ibias=IVmeasure.ibias;
vout=IVmeasure.voutc;%valor corregido de Vout.

%curva Vout-Ibias
subplot(2,2,1);plot(ibias,vout,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Ibias(A)');ylabel('Vout(V)');

%Curva Ites-Vtes
subplot(2,2,3);plot(IVstruct.vtes,IVstruct.ites,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Vtes(V)');ylabel('Ites(A)');

%Curva Ptes-Vtes
subplot(2,2,2);plot(IVstruct.vtes,IVstruct.ptes,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Vtes(V)');ylabel('Ptes(W)');

%Curva Ptes-rtes.
subplot(2,2,4);plot(IVstruct.rtes,IVstruct.ptes,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Rtes(%)');ylabel('Ptes(W)');
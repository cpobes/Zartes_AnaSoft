function plotIVs(Circuit,IVmeasure)
%Versión para usar como parámetros de entrada una estructura IVmeasure con
%toda la información necesaria.

IVstruct=GetIVTES(Circuit,IVmeasure);

% plot(vtes,ites,'.--'),grid on,hold on
% xlabel('Vtes(V)');ylabel('Ites(A)');

ibias=IVmeasure.ibias;
vout=IVmeasure.vout;%valor corregido de Vout.

%curva Vout-Ibias
subplot(2,2,1);plot(ibias*1e6,vout,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Ibias(\muA)');ylabel('Vout(V)');
set(gca,'fontsize',12,'linewidth',2,'weigth',bold)

%Curva Ites-Vtes
subplot(2,2,3);plot(IVstruct.vtes*1e6,IVstruct.ites*1e6,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Vtes(\muV)');ylabel('Ites(\muA)');
set(gca,'fontsize',12,'linewidth',2,'weigth',bold)

%Curva Ptes-Vtes
subplot(2,2,2);plot(IVstruct.vtes*1e6,IVstruct.ptes*1e12,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Vtes(\muV)');ylabel('Ptes(pW)');
set(gca,'fontsize',12,'linewidth',2,'weigth',bold)

%Curva Ptes-rtes.
subplot(2,2,4);plot(IVstruct.rtes,IVstruct.ptes*1e12,'.--','DisplayName',num2str(IVmeasure.Tbath)),grid on,hold on
xlabel('Rtes(%)');ylabel('Ptes(pW)');
set(gca,'fontsize',12,'linewidth',2,'weigth',bold)

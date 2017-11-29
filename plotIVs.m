function plotIVs(Circuit,IVmeasure)
%Versión para usar como parámetros de entrada una estructura IVmeasure con
%toda la información necesaria.

IVstruct=GetIVTES(Circuit,IVmeasure);

% plot(vtes,ites,'.--'),grid on,hold on
% xlabel('Vtes(V)');ylabel('Ites(A)');

for i=1:length(IVstruct)
ibias=IVstruct(i).ibias;
vout=IVstruct(i).vout;%valor corregido de Vout.

%curva Vout-Ibias
subplot(2,2,1);plot(ibias*1e6,vout,'.--','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlabel('Ibias(\muA)','fontweight','bold');ylabel('Vout(V)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')

%Curva Ites-Vtes
subplot(2,2,3);plot(IVstruct(i).vtes*1e6,IVstruct(i).ites*1e6,'.--','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlabel('Vtes(\muV)','fontweight','bold');ylabel('Ites(\muA)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')

%Curva Ptes-Vtes
subplot(2,2,2);plot(IVstruct(i).vtes*1e6,IVstruct(i).ptes*1e12,'.--','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlabel('Vtes(\muV)','fontweight','bold');ylabel('Ptes(pW)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')

%Curva Ptes-rtes.
subplot(2,2,4);plot(IVstruct(i).rtes,IVstruct(i).ptes*1e12,'.--','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlabel('Rtes(%)','fontweight','bold');ylabel('Ptes(pW)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')
end
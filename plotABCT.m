function plotABCT(P,varargin)

if nargin==1
    color='b';
elseif nargin>2
    color=varargin{1};
    TES=varargin{2};
end

gammas=[2 0.729]*1e3 %valores de gama para Mo y Au
rhoAs=[0.107 0.0983] %valores de Rho/A para Mo y Au
%sides=[200 150 100]*1e-6 %lados de los TES
sides=TES.sides;
hMo=55e-9, hAu=340e-9;
CN=(gammas.*rhoAs)*([hMo ;hAu]*sides.^2).*TES.Tc;
rpaux=0.1:0.01:0.9;
for i=1:length(P)
subplot(2,2,1)
[~,jj]=sort([P(i).p.rp]);
plot([P(i).p(jj).rp],abs([P(i).p(jj).C])*1e15,'.-','color',color),grid on,hold on
plot(rpaux,CN*1e15*ones(1,length(rpaux)),'-','color','r','linewidth',2)
plot(rpaux,2.43*CN*1e15*ones(1,length(rpaux)),'-','color','k','linewidth',2)
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('C(fJ/K)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)

subplot(2,2,2)
[~,jj]=sort([P(i).p.rp]);
semilogy([P(i).p(jj).rp],[P(i).p(jj).taueff],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('\tau_{eff}(s)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)

subplot(2,2,3)
[~,jj]=sort([P(i).p.rp]);
plot([P(i).p(jj).rp],[P(i).p(jj).ai],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('\alpha_i','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)

subplot(2,2,4)
[~,jj]=sort([P(i).p.rp]);
semilogy([P(i).p(jj).rp],[P(i).p(jj).bi],'.-','color',color),grid on,hold on
semilogy(0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2)
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('\beta_i','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)
end
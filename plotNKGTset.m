function plotNKGTset(Gset,varargin)

if nargin==1
    color='b';
elseif nargin==2
    color=varargin{1};
end
subplot(2,2,1)
plot([Gset.rp],[Gset.n],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('n','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')

subplot(2,2,2)
plot([Gset.rp],[Gset.Tc],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('Tc(K)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')

subplot(2,2,3)
plot([Gset.rp],[Gset.K],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('K(pW/K^n)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')

subplot(2,2,4)
plot([Gset.rp],[Gset.G],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('G(pW/K)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')
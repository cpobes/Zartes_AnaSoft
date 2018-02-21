function plotNKGTset(Gset,varargin)

if nargin==1
    %color='b';
    color=[0 0.447 0.741];
elseif nargin==2
    color=varargin{1};
end

MS=10;
LS=1;

subplot(2,2,1)
plot([Gset.rp],[Gset.n],'.-','color',color,'linewidth',LS,'markersize',MS),grid on,hold on
xlim([0.15 0.9])
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('n','fontsize',11,'fontweight','bold');
set(gca,'linewidth',2,'fontsize',11,'fontweight','bold')

subplot(2,2,2)
plot([Gset.rp],[Gset.Tc],'.-','color',color,'linewidth',LS,'markersize',MS),grid on,hold on
xlim([0.15 0.9])
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('Tc(K)','fontsize',11,'fontweight','bold');
set(gca,'linewidth',2,'fontsize',11,'fontweight','bold')

subplot(2,2,3)
plot([Gset.rp],[Gset.K]*1e-3,'.-','color',color,'linewidth',LS,'markersize',MS),grid on,hold on
xlim([0.15 0.9])
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('K(nW/K^n)','fontsize',11,'fontweight','bold');
set(gca,'linewidth',2,'fontsize',11,'fontweight','bold')

subplot(2,2,4)
plot([Gset.rp],[Gset.G],'.-','color',color,'linewidth',LS,'markersize',MS),grid on,hold on
xlim([0.15 0.9])
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('G(pW/K)','fontsize',11,'fontweight','bold');
set(gca,'linewidth',2,'fontsize',11,'fontweight','bold')
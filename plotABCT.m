function plotABCT(P,varargin)

if nargin==1
    color='b';
elseif nargin==2
    color=varargin{1};
end

for i=1:length(P)
subplot(2,2,1)
[~,jj]=sort([P(i).p.rp]);
plot([P(i).p(jj).rp],abs([P(i).p(jj).C])*1e15,'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('C(fJ/K)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')

subplot(2,2,2)
[~,jj]=sort([P(i).p.rp]);
semilogy([P(i).p(jj).rp],[P(i).p(jj).taueff],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('\tau_{eff}(s)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')

subplot(2,2,3)
[~,jj]=sort([P(i).p.rp]);
plot([P(i).p(jj).rp],[P(i).p(jj).ai],'.-','color',color),grid on,hold on
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('\alpha_i','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')

subplot(2,2,4)
[~,jj]=sort([P(i).p.rp]);
semilogy([P(i).p(jj).rp],[P(i).p(jj).bi],'.-','color',color),grid on,hold on
semilogy(0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2)
xlabel('Rtes(%Rn)','fontsize',11,'fontweight','bold');ylabel('\beta_i','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold')
end
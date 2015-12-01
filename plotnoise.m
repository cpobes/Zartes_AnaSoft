function plotnoise(varargin)
if nargin==0
    models={'wouter', 'irwin'};
else
    models=varargin(1);
end
f=logspace(0,6);
n=length(models);
for i=1:n
subplot(1,n,i)
noise=noisesim(models{i});
loglog(f,noise.jo,f,noise.ph,f,noise.sh,f,noise.sum)
grid on
title(models{i})
axis([1 1e5 1e-12 1e-10])
h=get(gca,'children');
set(h(1),'linewidth',3)
legend('jhonson','phonon','shunt','total')
% subplot(1,2,2)
% noise=noisesim('irwin');
% loglog(f,noise.jo,f,noise.ph,f,noise.sh,f,noise.sum)
% grid on
% title('irwin')
% axis([1 1e5 1e-12 1e-10])
% h=get(gca,'children')
% set(h(1),'linewidth',3)
% legend('jhonson','phonon','shunt','total')
end
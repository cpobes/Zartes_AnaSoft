function noise=plotnoise(varargin)
if nargin==0
    models={'wouter', 'irwin'};
else
    models=varargin(1);
    if nargin>1
        TES=varargin{2};
        OP=varargin{3};
        circuit=varargin{4};
    end
end
f=logspace(0,6);
n=length(models);
for i=1:n
subplot(1,n,i)
if nargin<=1
    noise=noisesim(models{i});
else
    noise=noisesim(models{i},TES,OP,circuit);
end
noise.squid=5e-12*ones(1,length(f));
% loglog(f,noise.jo,f,noise.ph,f,noise.sh,f,noise.squid,f,noise.sum+noise.squid)
% grid on
% title(models{i})
% axis([1 1e5 1e-12 2e-10])
% h=get(gca,'children');
% set(h(1),'linewidth',3)
% legend('jhonson','phonon','shunt','squid','total')
totnoise=noise.sum+noise.squid;
%totnoise=noise.sum;
loglog(f,totnoise)
h=get(gca,'children');
set(h(1),'linewidth',3)
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
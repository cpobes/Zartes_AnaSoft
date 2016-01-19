function compareTcmodels(dn,t,Tc0,varargin)
ds=[0:500];
%cla
%hold off
plot(ds,martinis(ds,dn,t,Tc0,1))
grid on
hold on
plotusadel(dn,t,Tc0)
legend('martinis','fominov')
xlabel('ds(nm)');
ylabel('Tc(mK)');
if nargin >3
    titulo=varargin{1};
    title(titulo);
end
function compareTcmodels(dn,t,Tc0)
ds=[0:500];
%cla
hold off
plot(ds,martinis(ds,dn,t,Tc0,0))
grid on
hold on
plotusadel(dn,t,Tc0)
legend('martinis','fominov')
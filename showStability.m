function showStability(TES)
%mostrar superficie de estabilidad para un TES.
Trange=[0:1e-3:1.1];Irange=[0:1e-3:1.1];
[X,Y]=meshgrid(Trange,Irange);
TES=SetOP(X*TES.Tc,Y*TES.Ic,TES);%llama a FtesTI.
stab=StabilityCheck(TES);%
%figure

hold off
%contourf(X,Y,FtesTI(X,Y));%evitar llamada a FtesTI.
contourf(X,Y,TES.R0/TES.Rn);
hold on
colormap gray
colormap(flipud(colormap))
alpha(0.1)
%contourf(Trange,Irange,~stab.stab);
contourf(X,Y,~stab.stab);
colormap cool
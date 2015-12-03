function showIVsims(Ttes,Ites,Ib,TESparam)

Rsh=TESparam.Rsh;Rpar=TESparam.Rpar;Rn=TESparam.Rn;
Ic=TESparam.Ic;Tc=TESparam.Tc;

%Vtes=Ib*Rsh-Ites*(Rsh+Rpar);
Rtes=Rn*FtesTI(Ttes/Tc,Ites/Ic);
Vtes=Ites.*Rtes;
Ptes=Ites.*Vtes;
%Rtes=Vtes./Ites;
rtes=Rtes/Rn;
%rtes=FtesTI(ttes,ites);
ites=Ites/Ic;
ttes=Ttes/Tc;
%subplot(1,2,1)
subplot(2,4,1);plot(Ib,Ites,'.-'),grid on
subplot(2,4,5);plot(Vtes,Ites,'.-'),grid on
subplot(2,4,2);plot(Vtes,Ptes,'.-'),grid on
subplot(2,4,6);plot(rtes,Ptes,'.-'),grid on

Trange=[0:1e-3:1.5];Irange=[0:1e-3:1.5];
[X,Y]=meshgrid(Trange,Irange);
TESparam=SetOP(X*Tc,Y*Ic,TESparam);
stab=StabilityCheck(TESparam);

subplot(1,2,2)
%contourf(X,Y,FtesTI(X,Y));
contourf(X*Tc,Y*Ic,TESparam.R0/Rn);
hold on

colormap gray
colormap(flipud(colormap))
alpha(0.1)
%contourf(Trange,Irange,~stab.stab);
contourf(X*Tc,Y*Ic,~stab.stab);
colormap cool
%plot3(ttes,ites,rtes,'.r','markersize',15)
plot3(Ttes,Ites,rtes,'.y','markersize',15)
Tb=Ttes(1);%ojo, esto no vale para barrido en bajada.
plotNSslopes(Tb,TESparam)
hold off


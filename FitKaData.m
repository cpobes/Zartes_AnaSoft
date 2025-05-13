function FitKaData(Pdata,Kaindex)
%%%funcion para crear, calibrar y ajustar datos de pulsos Ka.
%Asume que Pdata tiene ya campo OFT_Energy y que se han seleccionado
%en Kaindex los índices de los datos Kalfa.
nbins=50;
Ka1=5887.65;%maximo Ka1.
Ka2=5898.4;%maximo Ka2.
KData=Pdata.OFT_Energy(Kaindex);
%correct timeline fluctuations
%Twindow=40;
%KData=KData-movingMean(KData,Twindow)+KData(1);
%
[h,x]=hist(KData,nbins);
f = fit(x(:),h(:),'gauss2');
Ka_cal=polyfit([0 f.b2 f.b1],[0 Ka1 Ka2],2);
%calibrate data
[h,x]=hist(polyval(Ka_cal,KData),nbins);
MnKaHandle=BuildMnKaHandle;
p0=[100 5];
p=lsqcurvefit(MnKaHandle,p0,x(:),h(:));
%plot
figure('windowstyle','docked')
hist(polyval(Ka_cal,Pdata.OFT_Energy(Kaindex)),nbins);
grid on
hold
E=[5875:0.1:5910];
plot(E,MnKaHandle(p,E),'r','linewidth',3)
xlim([5875 5910]);
set(gca,'fontsize',15)
xlabel('E(eV)')
str=strcat('Fit \Gamma_E =',32,sprintf('%0.2f',p(2)),' eV');
legend({'K_\alpha data' str},'Location','northwest')
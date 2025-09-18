% instrucciones para formatear figura de espectro con Residuos.
%%%
figure('windowstyle','docked')
subplot(2,1,1);
SpPosition=[0.1300    0.2641    0.7750    0.6609];
%set(haux,'Position',SpPosition);
%pintar histograma
nbins=40;
%need to select data in indx and calibrate.
%Pauxdata=PX15data;
%EauxCal=X15_Ecal;
%calibrated_spectrum=EauxCal(Pauxdata.OFT_Energy(indx));
%hist(calibrated_spectrum,nbins);
%[h,x]=hist(calibrated_spectrum,nbins);
%bar(x,h)
x=xdata;h=ydata;
%bar(x,h)
x=1.0001*x;%%%!manual recalibration!
errorbar(x,h,sqrt(h),'linestyle',':','linewidth',1)
%formateo espectro
xlim([5875 5910]);
set(gca,'fontsize',15)
set(gca,'xtick',[]);%quitamos ejeX
grid on
hold on
%superponer fit o linea. 
E=[5840:0.1:5950];
plot(E,MnKaHandle(p,E),'r','linewidth',2);
legend({'K_{\alpha} data','3 eV Fit'});%modify text
title('15% R_n')%modify text
%%%plot residuos
%pause(1)
subplot(2,1,2);
RsPosition=[0.1300    0.1100    0.7750    0.1270];
set(gca,'Position',RsPosition);
%define.[h,x]=hist(calibrated_spectrum,nbins)
stem(x,h-MnKaHandle(p,x),'.-')
xlim([5875 5910])
set(gca,'fontsize',15)
xlabel('E(eV)')
R=sqrt(sum((h-MnKaHandle(p,x)).^2));
legend(strcat('R: ',num2str(R,4)));
legend boxoff
subplot(2,1,1)
set(gca,'Position',SpPosition);
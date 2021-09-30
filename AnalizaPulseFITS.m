function PulseParameters= AnalizaPulseFITS(file)
%%%%Funciona analoga a AnaliaaPulseDir pero para fichero fits
import matlab.io.*

info=fitsinfo(file);
Npulsos=info.BinaryTable.Rows
%Npulsos=10000;
t0ini=0.1;

fptr=fits.openFile(file)
%fits.movAbsHDU(fptr,3)%%%el fichero de la LNCS está en dos tablas. 
fits.movAbsHDU(fptr,2);
Npulsos=fits.getNumRows(fptr);
boolfit=0;
SR=str2num(fits.readKey(fptr,'SR'));
RL=str2num(fits.readKey(fptr,'RL'));
fhandle=@(p,t)p(1)*heaviside(t-p(4)).*(exp(-(t-p(4))/p(2))-exp(-(t-p(4))/p(3))+exp(-(t-p(4))/p(5)))/(p(2)+p(5)-p(3));
%p0=[0.7635    1.0460    0.0085    2.0009    6.4844]*1e-3;
%p0=[0.3979    0.8078    0.0048    2.0032    3.7450]*1e-3;
%p0=[5.6925e-04 4.7974*1e-3 4.5895*1e-6 2.0026*1e-3 0.9105*1e-3]; %%%Pulso promedio de los 6.4KeV del p40mK_142uA_PI08 de Julio2020.
p0=[4.2514e-04 4.0084*1e-3 7.0401*1e-6 2e-3 0.8903*1e-3]; %%%Pulso promedio de 6.4KeV a 90mK Julio2020.

time=(1:RL)/SR;
px=fhandle(p0,time);
ofilt=px/sum(px);

fh2=@(p,t)p(2)*ofilt+p(1);
%fnorm=@(p,t) heaviside(t-p(4)).*(exp(-(t-p(4))/p(2))-exp(-(t-p(4))/p(3))+exp(-(t-p(4))/p(5)))/(p(2)+p(5)-p(3));
fh3=@(p,t)p(2)*fhandle([1 p0(2) p0(3) p(3) p0(5)],time)+p(1);
for i=1:Npulsos
    %raw=fitsread(file,'binarytable',1,'TableColumns',1,'TableRows',1);%%5Lentisimo.
    try
        raw=fits.readCol(fptr,1,i,1);
    catch
        continue;
    end
    L=length(raw);
    pulso(:,1)=(1:L)/SR;%%%
    pulso(:,2)=-raw;%%%Pulsos negativos!
        
    dc(i)=mean(pulso(1:L*t0ini/2,2));
    dc_std(i)=std(pulso(1:L*t0ini/2,2));
    area(i)=sum(medfilt1(pulso(:,2),1)-dc(i));
    amp(i)=max(medfilt1(pulso(:,2),1))-dc(i);
    %energy(i)=sum((pulso(:,2)-dc(i))'.*ofilt);%%%estimacion OF.
    %energy0(i)=sum(pulso(:,2)'.*ofilt);
    %ind=find(pulso(:,2)-dc(i)<AMPthr);%%%seleccionamos un rango que no esté saturado para hacer el ajuste.
    %ind=find(pulso(:,1)<0.12 & pulso(:,1)>0.1);
    [v,t]=findpeaks(-pulso(:,2),pulso(:,1),'minpeakprominence',0.01);
    %v=0;t=0;
    npeaks(i)=numel(v);
    ntimes(i).times=t;
    
    timestamp(i)=fits.readCol(fptr,2,i,1);
    tbath(i)=fits.readCol(fptr,3,i,1);
    rsensor(i)=fits.readCol(fptr,4,i,1);
    
        if(boolfit)
        ind_fit=1:L;
        %p0=[0.01 0.001 1e-5];
        %fhandle=@(p,x)p(1)*(exp(-(x-t0)/p(2))-exp(-(x-t0)/p(3))).*heaviside(x-t0);%%%ojo a t0.
        %p0=[0.1 0.001 1e-5 0.002];ç
        %p0=[0.1 1e3 10 2000];
        %p0=[0.7635    1.0460    0.0085    2.0009    6.4844]*1e-3;
        %fhandle=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4));%%%simple
        %fhandle=@(p,t)p(1)*heaviside(t-p(4)).*(exp(-(t-p(4))/p(2))-exp(-(t-p(4))/p(3))+exp(-(t-p(4))/p(5)))/(p(2)+p(5)-p(3));
        %fhandle=@(p,x)p(1)*(1+p(5)*exp(-(x-p(4))/p(2))-(1+p(5))*exp(-(x-p(4))/p(3))).*heaviside(x-p(4));%%%step
        %p0=[0 404 2e-3];
        p0=[0.57 566 2e-3]; %%%p0 para fh3 del pulsopromedio del p40mK_142uA_PI08.
        %fit_pulso=lsqcurvefit(fhandle,p0,pulso(ind_fit,1),pulso(ind_fit,2)-dc(i));
        %size(fh2(p0,ind_fit))
        %size(pulso(ind_fit,2))
        %ft_p3=lsqcurvefit(fh3,p0,ind_fit,pulso(ind_fit,2)');
        ft_p3=lsqcurvefit(fh3,p0,pulso(:,1),pulso(:,2)');
        
        dcfit(i)=ft_p3(1);
        Afit(i)=ft_p3(2);
        t0fit(i)=ft_p3(3);
%         area_corrected(i)=sum(fhandle(fit_pulso,pulso(ind_fit,1)));
%         tau_rise(i)=fit_pulso(3);
%         tau_fall(i)=fit_pulso(2);
%         A(i)=fit_pulso(1);
%         t0(i)=fit_pulso(4);
    end
    if ~mod(i,10) ['pulso ' num2str(i)],end
end
fits.closeFile(fptr);
    PulseParameters.area=area;
    PulseParameters.dc=dc;
    PulseParameters.dc_std=dc_std;
    PulseParameters.amp=amp;
    PulseParameters.npeaks=npeaks;
    PulseParameters.ntimes=ntimes;
    %PulseParameters.energy=energy;
    %PulseParameters.e0=energy0;
    PulseParameters.timestamp=timestamp;
    PulseParameters.tbath=tbath;
    PulseParameters.rsensor=rsensor;
    if(boolfit)
%     PulseParameters.fit.area_corrected=area_corrected;
%     PulseParameters.fit.tau_rise=tau_rise;
%     PulseParameters.fit.tau_fall=tau_fall;
%     PulseParameters.fit.t0=t0;
%     PulseParameters.fit.A=A;
    PulseParameters.fit.dc=dcfit;
    PulseParameters.fit.Afit=Afit;
    PulseParameters.fit.t0fit=t0fit;
    end
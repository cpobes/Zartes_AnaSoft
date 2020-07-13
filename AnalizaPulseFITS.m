function PulseParameters= AnalizaPulseFITS(file)
%%%%Funciona analoga a AnaliaaPulseDir pero para fichero fits
import matlab.io.*

info=fitsinfo(file);
Npulsos=info.BinaryTable.Rows;
%Npulsos=10000;
t0ini=0.1;

fptr=fits.openFile(file)
fits.movAbsHDU(fptr,2)
boolfit=0;
for i=1:Npulsos
    %raw=fitsread(file,'binarytable',1,'TableColumns',1,'TableRows',1);%%5Lentisimo.
    raw=fits.readCol(fptr,1,i,1);
    L=length(raw);
    pulso(:,1)=1:L;%%%
    pulso(:,2)=raw;
        
    dc(i)=mean(pulso(1:L*t0ini/2,2));
    dc_std(i)=std(pulso(1:L*t0ini/2,2));
    area(i)=sum(medfilt1(pulso(:,2),10)-dc(i));
    amp(i)=max(medfilt1(pulso(:,2),10))-dc(i);
    %ind=find(pulso(:,2)-dc(i)<AMPthr);%%%seleccionamos un rango que no esté saturado para hacer el ajuste.
    %ind=find(pulso(:,1)<0.12 & pulso(:,1)>0.1);
    [v,t]=findpeaks(pulso(:,2),pulso(:,1),'minpeakprominence',0.05);
    %v=0;t=0;
    npeaks(i)=numel(v);
    ntimes(i).times=t;
    
    timestamp(i)=fits.readCol(fptr,2,i,1);
    %fits.readCol(fptr,1,i,1)
    tbath(i)=fits.readCol(fptr,3,i,1);
    rsensor(i)=fits.readCol(fptr,4,i,1);
    
        if(boolfit)
        ind_fit=1:L;
        %p0=[0.01 0.001 1e-5];
        %fhandle=@(p,x)p(1)*(exp(-(x-t0)/p(2))-exp(-(x-t0)/p(3))).*heaviside(x-t0);%%%ojo a t0.
        %p0=[0.1 0.001 1e-5 0.002];ç
        p0=[0.1 1e3 10 2000];
        fhandle=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4));%%%simple
        %fhandle=@(p,x)p(1)*(1+p(5)*exp(-(x-p(4))/p(2))-(1+p(5))*exp(-(x-p(4))/p(3))).*heaviside(x-p(4));%%%step
        fit_pulso=lsqcurvefit(fhandle,p0,pulso(ind_fit,1),pulso(ind_fit,2)-dc(i));
        area_corrected(i)=sum(fhandle(fit_pulso,pulso(ind_fit,1)));
        tau_rise(i)=fit_pulso(3);
        tau_fall(i)=fit_pulso(2);
        A(i)=fit_pulso(1);
        t0(i)=fit_pulso(4);
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
    PulseParameters.timestamp=timestamp;
    PulseParameters.tbath=tbath;
    PulseParameters.rsensor=rsensor;
    if(boolfit)
    PulseParameters.fit.area_corrected=area_corrected;
    PulseParameters.fit.tau_rise=tau_rise;
    PulseParameters.fit.tau_fall=tau_fall;
    PulseParameters.fit.t0=t0;
    PulseParameters.fit.A=A;
    end
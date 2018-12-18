function PulseParameters = AnalizaPulseDir( dir)
%ANALIZAPULSO Summary of this function goes here
%   Detailed explanation goes here

%N=2000;
%basename='PXI_Pulso_*';
basename='pulso_*';
files=ls(strcat(dir,'\',basename));
N=length(files(:,1))
t0=2e-3;
AMPthr=0.2;

if N>10000
    error('OJO: directorio grande');
end

for i=1:N
try
    %file=strcat(dir,'pulso_',num2str(i));
    pulso=importdata(strcat(dir,'\',files(i,:)));
    L=length(pulso(:,1))
    dc(i)=mean(pulso(1:L/10,2));
    dc_std(i)=std(pulso(1:L/10,2));
    area(i)=sum(pulso(:,2)-dc(i));
    amp(i)=max(pulso(:,2))-dc(i);
    ind=find(pulso(:,2)-dc(i)<AMPthr);%%%seleccionamos un rango que no esté saturado para hacer el ajuste.
    
    fhandle=@(p,x)p(1)*(exp(-(x-t0)/p(2))-exp(-(x-t0)/p(3))).*heaviside(x-t0);%%%ojo a t0.
    fit_pulso=lsqcurvefit(fhandle,[0.25 0.001 1e-5],pulso(ind,1),pulso(ind,2)-dc(i));
    area_corrected(i)=sum(fhandle(fit_pulso,pulso(:,1)));
    tau_rise(i)=fit_pulso(3);
    tau_fall(i)=fit_pulso(2);
    A(i)=fit_pulso(1);
    if ~mod(i,100) i,end
    
catch
        area(i)=0;
        dc(i)=0;
        dc_std(i)=0;
        amp(i)=0;
        area_corrected(i)=0;
        tau_rise(i)=0;
        tau_fall(i)=0;
        A(i)=0;
end
end
    PulseParameters.area=area;
    PulseParameters.dc=dc;
    PulseParameters.dc_std=dc_std;
    PulseParameters.amp=amp;
    %PulseParameters.fit_pulso=fit_pulso;
    PulseParameters.area_corrected=area_corrected;
    PulseParameters.A=A;
    PulseParameters.tau_rise=tau_rise;
    PulseParameters.tau_fall=tau_fall;
    

function [param,resN]=FitZfiles(fitinputs,TFSstr,IVmeasure,TES,Circuit,varargin)
%Función para ajustar automáticamente los datos de impedancia compleja.
%fitinputs contiene los valores de Ib a los que se ha tomado cada fichero,
%TFSstr es la TF en estado superconductor (la estructura leída con
%importTF) IVmeasure es la IV cogida a esa temperatura con formato
%estructura IV.(ib,vout,Tbath)

L=Circuit.L;
Rf=Circuit.Rf;
Itemp=IVmeasure.ib;
Vtemp=IVmeasure.vout;

Ibs=fitinputs.ibs;
%Zinf=fitinputs.zinfs;
%Z0=fitinputs.z0s;



fS=TFSstr.f;
%TFS=TFSstr.tf;
TFS=TFSstr;

if nargin>5,%%
    ind=varargin{1};
    if nargin>6,
    for i=1:length(varargin)-1
        h(i)=varargin{i+1};
    end
    end
else
    ind=1:length(TFSstr.f);
h(1)=figure;
h(2)=figure;
end

zt=plotZfiles(TFS,Circuit,ind,h(1),h(2))
for i=1:length(fitinputs.ibs), Zinf(i)=real(zt{i}(end));end%%funciona bien como estimación de los Z0.
for i=1:length(fitinputs.ibs), Z0(i)=real(zt{i}(1));end
tau0=1e-4;

for i=1:length(zt)
    p0=[Zinf(i) Z0(i) tau0];
    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,[real(zt{i}) imag(zt{i})]);%%%uncomment for real parameters.
    [p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(zt{i})]);%%%uncomment for real part only.
    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,zt{i});%%%uncommetn for complex parameters
    
    param(i)=GetModelParameters(p,IVmeasure,Ibs(i),TES,Circuit);
    resN(i)=aux1;
    %plot(fitZ(p,fS),'r')
    fZ=fitZ(p,fS);figure(h(1)),plot(fZ(:,1),fZ(:,2),'r');hold on
    figure(h(2)),semilogx(fS,fZ(:,1),'k',fS,fZ(:,2),'k'),hold on
end
figure
plot([param.rp],[param.C],'o-'),title('capacity'),grid on
xlabel('Rtes(%)');ylabel('C(J/K)');
figure
plot([param.rp],[param.ai],'o-'),title('alfa'),grid on
xlabel('Rtes(%)');ylabel('Alfa');
figure
plot([param.rp],[param.bi],'o-'),title('beta'),grid on
xlabel('Rtes(%)');ylabel('Beta');
figure
plot([param.rp],[param.tau0]./([param.L0]-1),'o-'),title('Tau_{eff}'),grid on
xlabel('Rtes(%)');ylabel('Tau_{eff}');
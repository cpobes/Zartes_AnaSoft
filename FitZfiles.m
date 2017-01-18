function [param,resN]=FitZfiles(IVmeasure,Circuit,TES,TFS,varargin)
%Función para ajustar automáticamente los datos de impedancia compleja.
%fitinputs contiene los valores de Ib a los que se ha tomado cada fichero,
%TFSstr es la TF en estado superconductor (la estructura leída con
%importTF) IVmeasure es la IV cogida a esa temperatura con formato
%estructura IV.(ibia,vout,Tbath)

L=Circuit.L;
Rf=Circuit.Rf;
Itemp=IVmeasure.ibias;
Vtemp=IVmeasure.vout;

%Ibs=fitinputs.ibs;
%Zinf=fitinputs.zinfs;
%Z0=fitinputs.z0s;



fS=TFS.f;

if nargin>4,%%
    ind=varargin{1};
    if nargin>5,
    for i=1:length(varargin)-1
        h(i)=varargin{i+1};
    end
    else
        h(1)=figure;
        h(2)=figure;
    end
else
    ind=1:length(fS);
h(1)=figure;
h(2)=figure;
end

[zt,files]=plotZfiles(TFS,Circuit,ind,h(1),h(2));

for i=1:length(zt), Zinf(i)=real(zt{i}(end));end%%funciona bien como estimación de los Z0.
for i=1:length(zt), Z0(i)=real(zt{i}(1));end
for i=1:length(zt), Y0(i)=real(1./zt{i}(1));end
tau0=1e-4;
feff0=1e2;

for i=1:length(zt)

    p0=[Zinf(i) Z0(i) tau0];
    %p0=[Zinf(i) Z0(i) tau0 1e-3 1e-6];%%%p0 for 2 block model.
    %pinv0=[Zinf(i) 1/Y0(i) tau0];%%%p0 for 1/Z fits.
    %size(zt{i})
    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,[real(zt{i}) imag(zt{i})]);%%%uncomment for real parameters.
    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,pinv0,fS,[real(1./zt{i}) imag(1./zt{i})]);%%%uncomment for inverse Ztes fit.
    [p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(zt{i})],[0 -Inf 0],[1 Inf 1]);%%%uncomment for real part only.

    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,zt{i});%%%uncommetn for complex parameters
    Ib=sscanf(char(regexp(files{i},'-?\d+.?\d+uA','match')),'%fuA')*1e-6
    
    %p=[p(1) 1/p(2) 1/p(3)];%solo para 1/Ztesvfits.
    param(i)=GetModelParameters(p,IVmeasure,Ib,TES,Circuit);
    resN(i)=aux1;
    
    %plot(fitZ(p,fS),'r')
    p(3)=abs(p(3));%%%
    fZ=fitZ(p,fS);figure(h(1)),plot(1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2);hold on
    %fZ=fitZ(p,fS);figure(h(1)),plot(fZ(:,1),fZ(:,2),'r');hold on
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
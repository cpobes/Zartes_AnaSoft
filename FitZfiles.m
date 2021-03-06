function [param,resN]=FitZfiles(IVset,Circuit,TES,TFS,varargin)
%Funci�n para ajustar autom�ticamente los datos de impedancia compleja.
%fitinputs contiene los valores de Ib a los que se ha tomado cada fichero,
%TFSstr es la TF en estado superconductor (la estructura le�da con
%importTF) IVmeasure es la IV cogida a esa temperatura con formato
%estructura IV.(ibia,vout,Tbath)

%%%Vmar2017 Uso: FitZfiles(IVset(1),circuit,TES,TFS)

L=Circuit.L;
Rf=Circuit.Rf;


%Ibs=fitinputs.ibs;
%Zinf=fitinputs.zinfs;
%Z0=fitinputs.z0s;



fS=TFS.f;
%fS=fS(50:length(TFS.f)-3000);
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

[zt,files,path]=plotZfiles(TFS,Circuit,ind,h(1),h(2));
%path
%taux=sscanf(path,'%dmK')
taux=regexp(path,'\d+mK','match');
taux=sscanf(taux{1},'%d');
    [~,Tind]=min(abs([IVset.Tbath]*1e3-taux));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IV=IVset(Tind);

Itemp=IV.ibias;
Vtemp=IV.vout;

for i=1:length(zt), Zinf(i)=real(zt{i}(end));end%%funciona bien como estimaci�n de los Z0.
for i=1:length(zt), Z0(i)=real(zt{i}(1));end
for i=1:length(zt), Y0(i)=real(1./zt{i}(1));end
indY=find(imag(zt{i})==min(imag(zt{i})));
tau0=1/(2*pi*fS(indY(1)));%%%tau0 es el valor inicial de taueff. Lo estimamos a partir de la w_min
%tau0=1e-5;
            tau1=1e-6;
            tau2=1e-6;
            d1=0.1;
            d2=0.1;
feff0=1e2;

fS=fS(ind);

for i=1:length(zt)

    p0=[Zinf(i) Z0(i) tau0];
    %p0=[Zinf(i) Z0(i) tau0 5e-6 5e-6];%%%p0 for 2 block model.
    
    %p0=[Zinf(i) Z0(i) tau0 tau1 tau2 d1 d2];%%%p0 for 3 block model.
    %pinv0=[Zinf(i) 1/Y0(i) tau0];%%%p0 for 1/Z fits.
    %size(zt{i})
    
    %%%[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,[real(zt{i}) imag(zt{i})]);%%%uncomment for real parameters.
    
    XDATA=fS;
    YDATA=[real(zt{i}) imag(zt{i})];
            model=BuildThermalModel();
            p0=model.X0;
            switch model.nombre
                case 'default'
                    p0=[Zinf(i) Z0(i) tau0];%%%
            end
            LB=model.LB;%%%[-Inf -Inf 0 0 0]
            UB=model.UB;%%%[]
            fitfunc=model.function;%%%@fitZ
    %%%%%Weigthed method
            weight=sqrt((XDATA));            
            costfunction=@(p)weight.*sqrt(sum((fitfunc(p,XDATA)-YDATA).^2,2));
            [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p0,LB,UB);%%%uncomment for real parameters.
            %[p,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitfunc,p0,XDATA,YDATA,LB,UB);
            ci = nlparci(p,aux2,'jacobian',auxJ);
    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,pinv0,fS,[real(1./zt{i}) imag(1./zt{i})]);%%%uncomment for inverse Ztes fit.
    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(zt{i})],[0 -Inf 0],[1 Inf 1]);%%%uncomment for real part only.

    %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,zt{i});%%%uncommetn for complex parameters
    Ib=sscanf(char(regexp(files{i},'-?\d+.?\d+uA','match')),'%fuA')*1e-6
    
    %p=[p(1) 1/p(2) 1/p(3)];%solo para 1/Ztesvfits.
    param(i)=GetModelParameters(p,IV,Ib,TES,Circuit);
    resN(i)=aux1;
    
    %plot(fitZ(p,fS),'r')
    p(3)=abs(p(3));%%%
    fZ=fitZ(p,fS);figure(h(1)),plot(1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2);hold on
    %fZ=fitZ(p,fS);figure(h(1)),plot(fZ(:,1),fZ(:,2),'r');hold on
    figure(h(2)),semilogx(fS,fZ(:,1),'k',fS,fZ(:,2),'k','linewidth',2),hold on
    %fid=fopen(strcat('Z(w)_',num2str(i),'.txt'),'wt');
    %[fS' real(zt{i})' imag(zt{i})']
    %fwrite(fid,[fS; real(zt{i}); imag(zt{i})],'single');
    dlmwrite(strcat('Z(w)_',num2str(i),'.txt'),[fS real(zt{i}) imag(zt{i})],'delimiter','\t');
    %fclose(fid)
end
if ~isnan(param(1).rp) && isfield(TES,'sides')
P.p=param;
for i=1:length(P.p)
    xxx(i,1)=P.p(i).rp*Circuit.Rn;xxx(i,2)=P.p(i).I0;xxx(i,3)=P.p(i).T0;
end
dlmwrite(strcat('Operating_Points','.txt'),xxx,'delimiter','\t');
figure
plotABCT(P,'b',TES)
end
% figure
% plot([param.rp],[param.C],'o-'),title('capacity'),grid on
% xlabel('Rtes(%)');ylabel('C(J/K)');
% figure
% plot([param.rp],[param.ai],'o-'),title('alfa'),grid on
% xlabel('Rtes(%)');ylabel('Alfa');
% figure
% plot([param.rp],[param.bi],'o-'),title('beta'),grid on
% xlabel('Rtes(%)');ylabel('Beta');
% figure
% plot([param.rp],[param.tau0]./([param.L0]-1),'o-'),title('Tau_{eff}'),grid on
% xlabel('Rtes(%)');ylabel('Tau_{eff}');
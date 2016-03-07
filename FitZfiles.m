function param=FitZfiles(Zinf,Z0,Ibs,fS,TFS,L,ind,Itemp,Vtemp,Rf,TES,varargin)

if nargin>11,
    for i=1:length(varargin)
        h(i)=varargin{i};
    end
else
h(1)=figure;
h(2)=figure;
end

zt=plotZfiles(TFS,L,ind,h(1),h(2))
tau0=1e-3;

for i=1:length(Zinf)
    p0=[Zinf(i) Z0(i) tau0];
    [p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,[real(zt{i}) imag(zt{i})]);%%%
    param(i)=GetModelParameters(p,Itemp,Vtemp,Ibs(i),Rf,TES);
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
function Gaux=fitPvsTset(IVTESset,perc,varargin)
%funcion para ajustar automaticamente curvas P-Tbath a un valor o valores
%de porcentaje de Rn. Ojo al uso de cells o arrays en IVset.
% varargin{1}=modelo [1, 2 o 3].

if nargin==2
    model=1;
else
    model=varargin{1};
end

%for i=1:length(IVTESset), Tbath(i)=IVTESset(i).Tbath;end

hold off;

for jj=1:length(perc)
    Paux=[];
    Iaux=[];
    Tbath=[];
    for i=1:length(IVTESset) 
        if isfield(IVTESset,'good') good=IVTESset(i).good;else good=1;end
            if good
        %txt=strcat('P',num2str(100*perc(jj)));
        %exec=strcat(txt,'(i)=','ppval(spline(IVTESset{i}.rtes,IVTESset{i}.ptes),jj)')
        %evalin('caller',exec);
        %ind=find(IVTESset(i).rtes>0.25&IVTESset(i).rtes<0.85);%%%algunas IVs fallan.
         ind=find(IVTESset(i).rtes>0.05&IVTESset(i).rtes<0.9);%%%algunas IVs fallan.
        if isempty(ind) continue;end
        Paux(end+1)=ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),perc(jj));
        Iaux(end+1)=ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),perc(jj));%%%
        Tbath(end+1)=IVTESset(i).Tbath;
            end
    end
    %fitaux=fit(Tbath',Paux'*1e12,'a*x^b+c','startpoint',[0 3 0]);
    %Tbath
    %Paux
    %Tbath=0.9932*Tbath+0.006171; %%Curva de calibración del termómetro Kelvinox al calibrado. Ver Tcal.m en medidas/TES.
    plot(Tbath,Paux*1e12,'bo','markerfacecolor','b'),hold on
    
    if model==1
        X0=[-500 3 1];XDATA=Tbath;LB=[-Inf 2 0 ];%%%Uncomment for model1
        X0=[65 9500 0.09]; %%%[A, B, Tc] en modelo a T^2+T^4
    elseif model==2
        %%%p(1)=-K, p(2)=n, p(3)=P0=K*Tc^n, p(4)=Ic0.
        %X0=[-5000 3.0 10 1e4 0]; XDATA=[Tbath;Iaux*1e6];LB=[-1e5 2 0 0 0];%%%Uncoment for model2
        X0=[-6500 3.03 13 1.9e4]; XDATA=[Tbath;Iaux*1e6];LB=[-1e5 2 0 0];
    elseif model==3
        %%%intento ajuste Gb
        auxtbath=min(Tbath):1e-4:max(Tbath);
        auxptes=spline(Tbath,Paux,auxtbath);
        gbaux=abs(diff(auxptes)./diff(auxtbath));
        fit2=lsqcurvefit(@(x,tbath)x(1)+x(2)*tbath,[3 2], log(auxtbath(2:end)),log(gbaux));
        Gaux(jj).n=(fit2(2)+1);
        Gaux(jj).K=exp(fit2(1))/Gaux(jj).n;
        figure(3),plot(log(auxtbath(2:end)),log(gbaux),'.-')
    end
    
    if model~=3
        fit=lsqcurvefit(@fitP,X0,XDATA,Paux*1e12,LB);
        plot(Tbath,fitP(fit,XDATA),'-r','linewidth',1)
        %     fitaux.a=fit(1);
        %     fitaux.b=fit(2);
        %     fitaux.c=fit(3);
        Gaux(jj)=GetGfromFit(fit);%%antes se pasaba fitaux.
    end
end
for jj=1:length(perc) Gaux(jj).rp=perc(jj);Gaux(jj).model=model;end

xlabel('T_{bath}(K)','fontsize',11,'fontweight','bold')
ylabel('P_{TES}(pW)','fontsize',11,'fontweight','bold')
%title('P vs T fits','fontsize',11,'fontweight','bold')
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')




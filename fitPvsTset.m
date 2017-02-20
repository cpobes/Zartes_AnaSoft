function Gaux=fitPvsTset(IVTESset,perc)
%funcion para ajustar automaticamente curvas P-Tbath a un valor o valores
%de porcentaje de Rn. Ojo al uso de cells o arrays en IVset.

for i=1:length(IVTESset), Tbath(i)=IVTESset(i).Tbath;end

for jj=1:length(perc)
    Paux=[];
    Iaux=[];
    for i=1:length(Tbath) 
        %txt=strcat('P',num2str(100*perc(jj)));
        %exec=strcat(txt,'(i)=','ppval(spline(IVTESset{i}.rtes,IVTESset{i}.ptes),jj)')
        %evalin('caller',exec);
        ind=find(IVTESset(i).rtes>0.15&IVTESset(i).rtes<0.95);%%%algunas IVs fallan.
        Paux(i)=ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),perc(jj));
        Iaux(i)=ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),perc(jj));%%%
    end
    %fitaux=fit(Tbath',Paux'*1e12,'a*x^b+c','startpoint',[0 3 0]);
    %Tbath
    %Paux
    plot(Tbath,Paux*1e12,'.'),hold on
    %X0=[-3500 3 1];XDATA=Tbath;LB=[-Inf 2 0 ];%%%Uncomment for model1
    X0=[-5000 3.0 10 1e4]; XDATA=[Tbath;Iaux*1e6];LB=[-Inf 2 0 0];%%%Uncoment for model2
    fit=lsqcurvefit(@fitP,X0,XDATA,Paux*1e12,LB);
    plot(Tbath,fitP(fit,XDATA),'-r')
%     fitaux.a=fit(1);
%     fitaux.b=fit(2);
%     fitaux.c=fit(3);
    Gaux(jj)=GetGfromFit(fit);%%antes se pasaba fitaux.
end
for jj=1:length(perc) Gaux(jj).rp=perc(jj);end
xlabel('T_{bath}(K)','fontsize',11,'fontweight','bold')
ylabel('P_{tes}(pW)','fontsize',11,'fontweight','bold')
title('P vs T fits','fontsize',11,'fontweight','bold')




function Gaux=fitPvsTset(IVTESset,perc)

for i=1:length(IVTESset), Tbath(i)=IVTESset{i}.Tbath;end

for jj=1:length(perc)
    Paux=[];
    for i=1:length(Tbath) 
        %txt=strcat('P',num2str(100*perc(jj)));
        %exec=strcat(txt,'(i)=','ppval(spline(IVTESset{i}.rtes,IVTESset{i}.ptes),jj)')
        %evalin('caller',exec);
        Paux(i)=ppval(spline(IVTESset{i}.rtes,IVTESset{i}.ptes),perc(jj));
    end
    %fitaux=fit(Tbath',Paux'*1e12,'a*x^b+c','startpoint',[0 3 0]);
    plot(Tbath,Paux*1e12,'.'),hold on
    fit=lsqcurvefit(@fitP,[-3500 3 1],Tbath,Paux*1e12);
    plot(Tbath,fitP(fit,Tbath),'-r')
    fitaux.a=fit(1);
    fitaux.b=fit(2);
    fitaux.c=fit(3);
    Gaux(jj)=GetGfromFit(fitaux);
end




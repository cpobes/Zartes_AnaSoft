function plotnoiseFile(IVstr,p,circuit,ZTES)
%pinta ruido y compara con Irwin a partir de fichero

[noise,file]=loadnoise();

if iscell(file)
    N=length(file)
    for i=1:N        
        Ib=sscanf(file{i},'HP_noise_%duA*')*1e-6;
        OP=setTESOPfromIb(Ib,IVstr,p);
        ncols=7;
        subplot(ceil(N/ncols),ncols,i)
        hold off;%figure
        loglog(noise{i}(:,1),V2I(noise{i}(:,2),circuit.Rf),'r'),hold on,grid on,
        plotnoise('irwin',ZTES,OP,circuit)
        set(gca,'xlim',[10 1e5]);
        set(gca,'ylim',[1e-11 1e-9]);
    end
else
        Ib=sscanf(file,'HP_noise_%duA*')*1e-6;
    OP=setTESOPfromIb(Ib,IVstr,p);

    hold off;%figure
    loglog(noise(:,1),V2I(noise(:,2),circuit.Rf),'r'),hold on,grid on,
    plotnoise('irwin',ZTES,OP,circuit)
end



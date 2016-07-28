function plotnoiseFile(IVstr,p,circuit,ZTES)
%pinta ruido y compara con Irwin a partir de fichero

[noise,file]=loadnoise();

Ib=sscanf(file,'HP_noise_%duA*')*1e-6;
OP=setTESOPfromIb(Ib,IVstr,p);

hold off;%figure
loglog(noise(:,1),V2I(noise(:,2),circuit.Rf),'r'),hold on,grid on,
plotnoise('irwin',ZTES,OP,circuit)



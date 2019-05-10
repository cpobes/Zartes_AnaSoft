function AnalizedData=AnalizeRun(circuit,TFS,varargin)

olddir=pwd;
if nargin>2
    dir=varargin{1};
    cd(dir);
end

faux=figure('visible','off');
[IVset,IVsetN]=LoadIVsets(circuit);%%%Cargamos las IVs
modelG=BuildPTbModel('GTcdirect'); %%%Definimos el modelo para el fit.
Gset=fitPvsTset(IVset,[0.05:0.01:0.9],modelG);
GsetN=fitPvsTset(IVsetN,[0.05:0.01:0.9],modelG);%%%Ajusto los datos P-Tbath.

RpTES=0.75;%%%Defino el %Rn al que fijar los datos del TES.
TES=BuildTESStructFromRp(RpTES,Gset);
TESN=BuildTESStructFromRp(RpTES,GsetN);

TES.Rn=circuit.Rn; %TES.sides=(lado). Actualizo la estructura TES para incluir Rn.
TESN.Rn=66.9e-3;%%%<-%%%%%%
TFS=importTF('TFS.txt');%%%Necesitamos la TF en estado 'S'!

P=FitZset(IVset,circuit,TES,TFS);%%%Ajustamos las Z positivas.
cd 'Negative Bias'
PN=FitZset(IVsetN,circuit,TESN,TFS); 
cd ..

cd(olddir)

AnalizedData.IVset=IVset;
AnalizedData.IVsetN=IVsetN;
AnalizedData.modelG=modelG;
AnalizedData.Gset=Gset;
AnalizedData.GsetN=GsetN;
AnalizedData.RpTES=RpTES;
AnalizedData.TES=TES;
AnalizedData.TESN=TESN;
AnalizedData.P=P;
AnalizedData.PN=PN;

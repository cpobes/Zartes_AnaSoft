function AnalizedData=AnalizeRun(analizeOptions)
%%%%%Función para lanzar un aálisis automático sobre un RUN completo desde
%%%%%cualquier directorio de análisis. Podemos pasar como argumento sólo el
%%%%%datadir (path al run a analizar) y cogerá opciones por defecto, o
%%%%%pasar una estructura con las opciones de análisis, donde el datadir es
%%%%%obligatorio y el resto si no están, se cogen por defecto.

olddir=pwd;
if ischar(analizeOptions)
    datadir=analizeOptions;
else
    datadir=analizeOptions.datadir;
end

if isfield(analizeOptions,'PTrange')
    PTrange=analizeOptions.PTrange;
else
    PTrange=[0.05:0.01:0.9];
end

if isfield(analizeOptions,'PTmodel')
    PTmodel=analizeOptions.PTmodel;
else
    PTmodel=BuildPTbModel('GTcdirect'); %%%Definimos el modelo para el fit.
end

if isfield(analizeOptions,'RpTES')
    RpTES=analizeOptions.RpTES;
else
    RpTES=0.75;
end

if isfield(analizeOptions,'ZfitOpt')
    ZfitOpt=analizeOptions.ZfitOpt;
else
    ZfitOpt.TFdata='HP';
    ZfitOpt.Noisedata='HP';
    ZfitOpt.f_ind=[1 1e5];
    %ZfitOpt.Temps=50;%Temp en mK.
    ZfitOpt.ThermalModel='irwin';
end
% if nargin>2
%     dir=varargin{1};
%     cd(dir);
% end

faux=figure('visible','off');
[IVset,IVsetN]=LoadIVsets(datadir);%%%Cargamos las IVs
Gset=fitPvsTset(IVset,PTrange,PTmodel);
GsetN=fitPvsTset(IVsetN,PTrange,PTmodel);%%%Ajusto los datos P-Tbath.
close(faux);

%RpTES=0.75;%%%Defino el %Rn al que fijar los datos del TES.
TES=BuildTESStructFromRp(RpTES,Gset);
TESN=BuildTESStructFromRp(RpTES,GsetN);

%TES.Rn=circuit.Rn; %TES.sides=(lado). Actualizo la estructura TES para incluir Rn.
%TESN.Rn=TES.Rn;%66.9e-3;%%%<-%%%%%%
%TFS=importTF('TFS.txt');%%%Necesitamos la TF en estado 'S'!

TESDATA=BuildDataStruct;
%P=FitZset(IVset,circuit,TES,TFS);%%%Ajustamos las Z positivas.
P=FitZset_remote(TESDATA,ZfitOpt);

%%%Solicion temporal para analizar tb negativas.
cd(strcat(datadir,'\Negative Bias'))
TESDATAN.IVset=IVsetN;
TESDATAN.circuit=TESDATA.circuit;
TESDATAN.TES=TESN;
%TESDATAN.TFS=TESDATA.TFS;
TFS=importTF('..\TFS.txt');
TESDATAN.TFS=TFS;
PN=FitZset_remote(TESDATAN,ZfitOpt);
%PN=FitZset(IVsetN,circuit,TESN,TFS); 
cd ..

cd(olddir)

AnalizedData.circuit=TESDATA.circuit;
AnalizedData.IVset=IVset;
AnalizedData.IVsetN=IVsetN;
AnalizedData.PTmodel=PTmodel;
AnalizedData.Gset=Gset;
AnalizedData.GsetN=GsetN;
AnalizedData.RpTES=RpTES;
AnalizedData.TES=TES;
AnalizedData.TESN=TESN;
AnalizedData.P=P;
AnalizedData.PN=PN;
AnalizedData.analizeOptions=analizeOptions;

function plotnoiseTbathRp(ZTESDATA,Tbathstring,Rps,varargin)
%%%%Función para pintar ruidos a una Tbath determinada y unos %Rp dados

IVset=ZTESDATA.IVset;
P=ZTESDATA.P;
circuit=ZTESDATA.circuit;
TES=ZTESDATA.TES;

if nargin==3
    option=BuildNoiseOptions;
else
    option=varargin{1};
end

Tbath=sscanf(Tbathstring,'%f');
files=GetFilesFromRp(IVset(GetTbathIndex(Tbath,IVset,P)),Tbath,Rps,option.NoiseBaseName);
plotnoiseFile(IVset,P,circuit,TES,Tbathstring,files,option);
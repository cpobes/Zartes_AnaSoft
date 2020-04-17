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

olddir=pwd;
% if isfield(option,'datadir')
%     cd(option.datadir)
% end
if isfield(ZTESDATA,'analizeOptions')
    cd(ZTESDATA.analizeOptions.datadir)
end
isnumeric(Tbathstring) & Tbathstring<1
if ischar(Tbathstring)
    Tbath=sscanf(Tbathstring,'%f');
end
if isnumeric(Tbathstring) & Tbathstring<1
    Tbath=Tbathstring*1e3;
else
    Tbath=Tbathstring;
end
Tdir=GetDirfromTbath(Tbath);
files=GetFilesFromRp(IVset(GetTbathIndex(Tbath,IVset,P)),Tbath,Rps,option.NoiseBaseName)
plotnoiseFile(IVset,P,circuit,TES,Tdir,files,option);
cd(olddir);
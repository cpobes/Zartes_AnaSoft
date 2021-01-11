function P=FitZset_remote(TESDATA,varargin)
%%%%Funcion para poder lanzar el FitZset desde cualquier directorio de
%%%%análisis sin tener que cambiarse al directorio de datos. Modifico tb
%%%%FitZset para poder pasar estructura con opciones. 
%%% !!!!Ojo porque si
%%%%queremos analizar los datos de la PXI la TFS en TESDATA tiene que ser
%%%%la TFS_PXI (con la length adecuada) y para analizar datos con bias
%%%%negativos hay que crear un TESDATA con las IVs etc negativas y el data
%%%%dir que incluya tb el \Negative_bias

IVset=TESDATA.IVset;
circuit=TESDATA.circuit;
TES=TESDATA.TES;
%TFS=TESDATA.TFS;

olddir=pwd;

if isfield(TESDATA,'datadir')
    cd(TESDATA.datadir)
    try
        TFS=importTF('TFS.txt');%%%%Necesitamos crear TFS en el dir de analisis
    catch
        'hola, di error'    
    end
    if isfield(TESDATA,'TFS') TFS=TESDATA.TFS;end %%%Podemos sobreescribir la TFS con otra.
    if nargin==2
        opt=varargin{1};
        P=FitZset(IVset,circuit,TES,TFS,opt);
    else
        P=FitZset(IVset,circuit,TES,TFS);
    end
    cd(olddir);
else
    try
        TFS=importTF('TFS.txt');%%%%Necesitamos crear TFS en el dir de analisis
    catch
    end
    if isfield(TESDATA,'TFS') TFS=TESDATA.TFS;end
    if nargin==2
        opt=varargin{1};
        P=FitZset(IVset,circuit,TES,TFS,opt);
    else
        P=FitZset(IVset,circuit,TES,TFS);
    end
end

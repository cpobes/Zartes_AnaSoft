function IVset=importFullIV(varargin)
%%%Nueva versión de la funcion de importacion de IVs con alguna
%%%modificacion.
%%importamos
if nargin==0
[file,path]=uigetfile('C:\Documents and Settings\Usuario\Escritorio\Datos\2016\Noviembre\IVs\*','','multiselect','on');
end

%podemos pasar los ficheros a analizar como un cellarray.
if nargin==1
    file=varargin{1};
    path=pwd;
    path=strcat(path,'\');
end
T=strcat(path,file)
if ~iscell(T)
    [ii,jj]=size(T);
    for i=1:ii, T2{i}=T(i,:);end
    T=T2;
end
if ~iscell(file)
    [ii,jj]=size(file);
    for i=1:ii, file2{i}=file(i,:);end
    file=file2;
end
for i=1:length(T)
    T{i}
    %cargamos datos.Ojo al formato.
    %data=importdata(T{i},'\t');%%%si hay header hace falta skip.
    data=importdata(T{i});
    if isstruct(data) data=data.data;end
    %corregir el vout.
    %auxS=corregir4ramas(data);%%para importar ficheros con 4 ramas (sin header)
    auxS=corregir1rama(data);%% para importar ficheros con 1 rama.
    auxS.Tbath=sscanf(file{i},'%0.1fmK*')*1e-3;
    IVset(i)=auxS;
end
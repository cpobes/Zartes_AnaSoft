function [IVset,IVsetN]=LoadIVsets(varargin)
%%%%Funci�n para cargar las IVset directamente listando etc.
%%%%%% V2.(11-junio-2019). Modifico la funci�n para poder pasar en
%%%%%% cualqueir orden dos par�metros, el datadir y el circuit. Si no le
%%%%%% paso el circuit lo busca en el workspace y si no en el datadir. Si
%%%%%% no encuentra circuit las carga pero sin calcular Ites,Vtes, etc.
%%%%%% S�lo si se intenta ejecutar sin pasar el datadir desde un directorio
%%%%%% sin datos dar� error. Con esta nueva versi�n se puede estar
%%%%%% analizando desde un directorio de an�lisis sin tener que ir saltando
%%%%%% al dir de datos. Combinarla con FitZset_remote.

colordir=GetCloudDataDir();%%%La variable colores est� en el directorio raiz principal de los datos en la nube.
% command=strcat('''load(''''',colordir,'\','colores.mat',''''')''')
% evalin('caller',command); no funciona.

olddir=pwd;

cd(colordir)%%%Cargamos automaticamente la estructura colores para trabajar con ella
%evalin('caller','load(''colores.mat'')');
load('colores.mat');
cd(olddir)

datadir=[];
circuit=[];

for i=1:length(varargin) 
    if ischar(varargin{i})
        datadir=varargin{i};
    end
    if isstruct(varargin{i})
        circuit=varargin{i};
    end
end

    if ~isempty(datadir)
        cd(datadir);
    end
    
filesP=ListInTbathOrder('IVs\*_p_*matlab.txt');
filesN=ListInTbathOrder('IVs\*_n_*matlab.txt');

cd 'IVs'
%IVset=ImportFullIV(filesP);
IVset=ImportRawIVs(filesP);
%IVsetN=ImportFullIV(filesN);
IVsetN=ImportRawIVs(filesN);
cd ..

    if isempty(circuit)
        vars=evalin('caller','who')
        if sum(strcmp(vars,'circuit'))
        circuit=evalin('caller','circuit');%%%%Ojo, primero coge el circuit del WS si existe.
        %IVset=ApplyOffset(IVset,circuit);
        %circuit.voffset=-1.1249;%%%!!!
        IVset=CentrarIVs(IVset,circuit);
        IVset=GetIVTES(circuit,IVset);
        %IVsetN=ApplyOffset(IVsetN,circuit);
        %circuit.voffset=1.0091;%%%!!!
        IVsetN=CentrarIVs(IVsetN,circuit);
        IVsetN=GetIVTES(circuit,IVsetN);
        else
            try
                evalin('caller','load(''circuit.mat'')');
                vars=evalin('caller','who');
                circuit=evalin('caller','circuit');
                %IVset=ApplyOffset(IVset,circuit);
                IVset=CentrarIVs(IVset,circuit);
                IVset=GetIVTES(circuit,IVset);
                %IVsetN=ApplyOffset(IVsetN,circuit);
                IVsetN=CentrarIVs(IVsetN,circuit);
                IVsetN=GetIVTES(circuit,IVsetN);
            catch
                    if ~isempty(datadir)
                        cd(olddir);
                    end
                warning('no circuit structure')    
                return
            end
            
        end
    else
        %IVset=ApplyOffset(IVset,circuit);
        IVset=CentrarIVs(IVset,circuit);
        IVset=GetIVTES(circuit,IVset);
        %IVsetN=ApplyOffset(IVsetN,circuit);
        IVsetN=CentrarIVs(IVsetN,circuit);
        IVsetN=GetIVTES(circuit,IVsetN);
    end
    
        if ~isempty(datadir)
        cd(olddir);
    end
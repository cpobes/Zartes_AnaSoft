function [IVset,IVsetN]=LoadIVsets(varargin)
%%%%Función para cargar las IVset directamente listando etc.
%%%%%% V2.(11-junio-2019). Modifico la función para poder pasar en
%%%%%% cualqueir orden dos parámetros, el datadir y el circuit. Si no le
%%%%%% paso el circuit lo busca en el workspace y si no en el datadir. Si
%%%%%% no encuentra circuit las carga pero sin calcular Ites,Vtes, etc.
%%%%%% Sólo si se intenta ejecutar sin pasar el datadir desde un directorio
%%%%%% sin datos dará error. Con esta nueva versión se puede estar
%%%%%% analizando desde un directorio de análisis sin tener que ir saltando
%%%%%% al dir de datos. Combinarla con FitZset_remote.

colordir='G:\Unidades compartidas\X-IFU\Datos\Datos Dilución';

% command=strcat('''load(''''',colordir,'\','colores.mat',''''')''')
% evalin('caller',command); no funciona.

olddir=pwd;

cd(colordir)%%%Cargamos automaticamente la estructura colores para trabajar con ella
evalin('caller','load(''colores.mat'')');
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
    
filesP=ListInTbathOrder('IVs\*_p_*');
filesN=ListInTbathOrder('IVs\*_n_*');

cd 'IVs'
IVset=ImportFullIV(filesP);
IVsetN=ImportFullIV(filesN);
cd ..

    if isempty(circuit)
        vars=evalin('caller','who')
        if sum(strcmp(vars,'circuit'))
        circuit=evalin('caller','circuit');
        IVset=GetIVTES(circuit,IVset);
        IVsetN=GetIVTES(circuit,IVsetN);
        else
            try
                evalin('caller','load(''circuit.mat'')');
                vars=evalin('caller','who');
                circuit=evalin('caller','circuit')
                IVset=GetIVTES(circuit,IVset);
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
        IVset=GetIVTES(circuit,IVset);
        IVsetN=GetIVTES(circuit,IVsetN);
    end
    
        if ~isempty(datadir)
        cd(olddir);
    end
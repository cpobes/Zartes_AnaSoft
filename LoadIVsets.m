function [IVset,IVsetN]=LoadIVsets()
%%%%Función para cargar las IVset directamente listando etc.

filesP=ListInTbathOrder('IVs\*_p_*');
filesN=ListInTbathOrder('IVs\*_n_*');

cd 'IVs'
IVset=ImportFullIV(filesP);
IVsetN=ImportFullIV(filesN);

cd ..

vars=evalin('caller','who')

if sum(strcmp(vars,'circuit'))
    circuit=evalin('caller','circuit')
    IVset=GetIVTES(circuit,IVset);
    IVsetN=GetIVTES(circuit,IVsetN);
end

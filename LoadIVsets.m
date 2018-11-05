function [IVset,IVsetN]=LoadIVsets()
%%%%Función para cargar las IVset directamente listando etc.

filesP=ListInTbathOrder('IVs\*_p_*');
filesN=ListInTbathOrder('IVs\*_n_*');

cd 'IVs'
IVset=ImportFullIV(filesP);
IVsetN=ImportFullIV(filesN);

cd ..
%IVset=GetIVTES(circuit,IVset,TES);
%IVsetN=GetIVTES(circuit,IVsetN,TES);

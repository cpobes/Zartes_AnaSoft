function IVset=ApplyOffset(auxS,circuit)
%%funcion para aplicar un offset a las IVs.
%suponemos que se han centrado previamente en el cero.

IVset=auxS;
if isfield(circuit,'ioffset')
    ioff=circuit.ioffset;
else
    ioff=0;
end

m=circuit.mN;%%Dependiendo de la forma de corregir, podemos aplicar mS o mN.
for i=1:length(auxS) %%%si lo aplico al IVset completo hay que hacer bucle.
    IVset(i).ibias=auxS(i).ibias-ioff;
    IVset(i).vout=auxS(i).vout-ioff*m;
end
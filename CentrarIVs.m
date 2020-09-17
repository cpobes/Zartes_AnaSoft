function IVset=CentrarIVs(RawIVset,circuit)
%%%funcion para centrar raw IVs a partir de un offset

if isfield(circuit,'ioffset')
    ioff=circuit.ioffset;
else
    ioff=0;
end
for i=1:length(RawIVset)
    ind=find(abs(RawIVset(i).ibias)<10);%%%seleccionamos el rango de corrietnes cercano a 0.
    if isfield(circuit,'voffset')
        voff=circuit.voffset;
    else
        voff=nan;
    end
        if isnan(voff)
        voff=spline(RawIVset(i).ibias(ind),RawIVset(i).vout(ind),ioff);
        end
    IVset(i).ibias=RawIVset(i).ibias-ioff;
    IVset(i).vout=RawIVset(i).vout-voff;
    IVset(i).Tbath=RawIVset(i).Tbath;
end
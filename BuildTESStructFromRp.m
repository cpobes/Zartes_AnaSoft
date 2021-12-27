function TES=BuildTESStructFromRp(rp,Gset)
%%%Genera la estructura TES a partir del Gset y de un porcentaje.

ind=find(round(100*[Gset.rp])==100*rp);%%%Ojo si rp no est� entre el rango de valores de Gset.rp

TES=Gset(ind);
TES.K=TES.K*1e-12;
TES.G=TES.G*1e-12;
TES.G100=TES.G100*1e-12;
TES.G0=TES.G;

vars=evalin('caller','who');

if sum(strcmp(vars,'circuit'))
    circuit=evalin('caller','circuit');
    TES.Rn=circuit.Rn;
end

TES.Ttes=@(P,Tbath)((P./TES.K+Tbath.^(TES.n)).^(1./(TES.n)));
TES.Gtes=@(Ttes)(TES.n*TES.K*Ttes.^(TES.n-1));
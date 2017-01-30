function Ibs=BuildIbiasFromRp(IVstr_i,rp)
%%%Función para devolver un vector de valores de Ibias para unos %Rn dados

ind=find(IVstr_i.rtes>0.01);
Ibs=round(spline(IVstr_i.rtes(ind),IVstr_i.ibias(ind),rp)*1e6);

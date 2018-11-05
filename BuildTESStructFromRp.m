function TES=BuildTESStructFromRp(rp,Gset)
%%%Genera la estructura TES a partir del Gset y de un porcentaje.
ind=find([Gset.rp]==rp);
TES=Gset(ind);
TES.K=TES.K*1e-12;
TES.G=TES.G*1e-12;
TES.G100=TES.G100*1e-12;
TES.G0=TES.G;
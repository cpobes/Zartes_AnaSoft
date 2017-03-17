function Ibs=BuildIbiasFromRp(IVset,rp)
%%%Función para devolver un vector de valores de Ibias para unos %Rn dados
%%% v0: solo una IV
%%% v1: todo el IVset y devuelve IZvalues. falla.

for i=1:length(IVset)
    
    ind=find(IVset(i).rtes>0.01);
    Ibs=round(spline(IVset(i).rtes(ind),IVset(i).ibias(ind),rp)*1e6);
    %f=strcat('i',num2str(IVset(i).Tbath*1e3))
    %cmd=strcat('setfield(IZvalues,',f,',Ibs',');')
    %eval(cmd)
    %assignin('caller',cmd,Ibs)
end

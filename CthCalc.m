function CN=CthCalc(TES)
%%%función para calcular la C teorica de un TES de Mo Au en estado normal

gammas=[2 0.729]*1e3; %valores de gama para Mo y Au
rhoAs=[0.107 0.0983];%valores de Rho/A para Mo y Au
%sides=[200 150 100]*1e-6 %lados de los TES
sides=TES.sides;

hMo=55e-9; hAu=340e-9;
if isfield(TES,'hMo') hMo=TES.hMo;end
if isfield(TES,'hAu') hAu=TES.hAu;end
%hAu
if length(hAu)==1 hAu=hAu*ones(1,length(TES.Tc));end
for i=1:length(hAu)    
    %(gammas.*rhoAs)*([hMo ;hAu(i)]*sides.^2).*TES.Tc
CN(i)=(gammas.*rhoAs)*([hMo ;hAu(i)]*sides.^2).*TES.Tc(i);
%[hAu(i)*1e9 TES.Tc(i) CN(i)*1e15]
end
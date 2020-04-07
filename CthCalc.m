function CN=CthCalc(TES)
%%%función para calcular la C teorica de un TES de Mo Au en estado normal
%%%Se calcula sólo la contribución electronica a partir de la expresión 111
%%%de Irwin y los valroes de la tabla.

gammas=[2 0.729 0.008]*1e-3; %valores de gama para Mo y Au y Bi. Multiplicado por 1e-3 para J/molK^2
rhoAs=[0.107 0.0983 0.0468]*1e6;%valores de Rho/A para Mo y Au. Multiplcado por 1e6 para mol/m^3
%sides=[200 150 100]*1e-6 %lados de los TES
sides=TES.sides;

%hMo=55e-9; hAu=340e-9;
hMo=45e-9; hAu=265e-9;
hBi=0;%6e-6;
if isfield(TES,'hMo') hMo=TES.hMo;end
if isfield(TES,'hAu') hAu=TES.hAu;end
if isfield(TES,'hBi') hBi=TES.hBi;end
%hAu

sides^2*hBi*rhoAs(3)
%hAu=1.1e-6;
if length(hAu)==1 hAu=hAu*ones(1,length(TES.Tc));end
for i=1:length(hAu)    
    %(gammas.*rhoAs).*(([hMo ;hAu(i);hBi]*sides.^2)').*TES.Tc %%%show each
    %contribution.
CN(i)=(gammas.*rhoAs)*([hMo ;hAu(i);hBi]*sides.^2).*TES.Tc(i)
%[hAu(i)*1e9 TES.Tc(i) CN(i)*1e15]
end
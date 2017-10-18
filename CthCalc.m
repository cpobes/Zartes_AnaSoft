function CN=CthCalc(TES)
%%%función para calcular la C teorica de un TES de Mo Au en estado normal

gammas=[2 0.729]*1e3; %valores de gama para Mo y Au
rhoAs=[0.107 0.0983];%valores de Rho/A para Mo y Au
%sides=[200 150 100]*1e-6 %lados de los TES
sides=TES.sides;
hMo=55e-9; hAu=340e-9;
CN=(gammas.*rhoAs)*([hMo ;hAu]*sides.^2).*TES.Tc;
function plotTESR_T(Circuit,IVmeasure,TES)
%%pinta la R(T) de un TES a partir de una curva IV pasada como estructura.
%%Esta función funciona sólo para una única curva.

if isfield(IVmeasure,'ttes')
    IVstruct=IVmeasure;
else
    IVstruct=GetIVTES(Circuit,IVmeasure,TES);
end

plot(IVstruct.ttes,IVstruct.Rtes,'.-','DisplayName',strcat(num2str(1000*IVmeasure.Tbath),'mK'));
xlabel('T_{tes}(K)');ylabel('R_{tes}(\Omega)');grid on
legend('-DynamicLegend')
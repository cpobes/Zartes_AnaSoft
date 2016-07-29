function plotTESR_T(Circuit,IVmeasure,TES)
%%pinta la R(T) de un TES a partir de una curva IV pasada como estructura.
%%Esta funci�n funciona s�lo para una �nica curva.

for i=1:length(IVmeasure)
    if isfield(IVmeasure(i),'ttes')
        IVstruct=IVmeasure(i);
    else
        IVstruct=GetIVTES(Circuit,IVmeasure(i),TES);
    end

    plot(IVstruct.ttes,IVstruct.Rtes,'.-','DisplayName',strcat(num2str(1000*IVstruct.Tbath),'mK'));
    xlabel('T_{tes}(K)');ylabel('R_{tes}(\Omega)');grid on,hold on
    legend('-DynamicLegend')
end
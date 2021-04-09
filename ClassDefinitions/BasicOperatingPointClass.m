classdef BasicOperatingPointClass < handle
    %%%%%Propuesta de clase para encapsular un punto de operación básico
    %%%%%del TES sin parámetros dinámicos. Requiere todavía del circuit y
    %%%%%del TES en formato struct. Es análoga al GetIVTES.
    
    properties
        %%%circuit
        fCircuit=[];
        %%%Direct Experimental
        fTbath=0.1;
        fIbias=100e-6;
        fVout=0;
        %%%Deduced
        fR0=0;
        fI0=0;
        fV0=0;
        fT0=0;
        fP0=0;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=BasicOperatingPointClass(OPstruct,SETUP)
            %%%Pasamos Tb,Ib,Vo como structura y circuit y TES tb.
            Tbath=OPstruct.Tbath;
            Ibias=OPstruct.Ibias;
            Vout=OPstruct.Vout;
            circuit=SETUP.circuit;
            TES=SETUP.TES;
            fTES=TES;
            fCircuit=circuit;
            fTbath=Tbath;
            fIbias=Ibias;
            fVout=Vout;
            
            fI0=V2I(Vout,circuit);
            Vs=(fIbias-fI0)*circuit.Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
            fV0=Vs-fI0*circuit.Rpar;
            fP0=fV0.*fI0;
            fR0=fV0./fI0;
            fT0=(fP0./[TES.K]+Tbath.^([TES.n])).^(1./[TES.n]);
        end
    end
end
function IVstruct=GetIVTES(Circuit,IVmeasure,varargin)
%Version de GetIVTES que devuelve estructura y acepta estructura de
%Circuito y Medida.
%Get ites and vtes from measured vout and ibias and values of Rf and Rsh.



for i=1:length(IVmeasure)
    Tbath=IVmeasure(i).Tbath

    %!
    %IVmeasure(i).voutc=IVmeasure.vout;
    %IVmeasure(i).ibias=IVmeasure.ib;
    
    invMf=Circuit.invMf;
    invMin=Circuit.invMin;
    Rpar=Circuit.Rpar;
    Rsh=Circuit.Rsh;
    Rf=Circuit.Rf;
    Rn=Circuit.Rn; %Sólo 

    if nargin==3
        TES=varargin{1};
        Rn=TES.Rn; %Si no cargamos la estructura TES, la Rn podemos pasarla a través de la estructura Circuit. Pasar TES tiene sentido para usar la 'K' y 'n' para deducir la Ttes.
    end

    F=invMin/(invMf*Rf);%36.51e-6;
    %F=36.52e-6;
    ites=IVmeasure(i).vout*invMin/(invMf*Rf);
    Vs=(IVmeasure(i).ibias-ites)*Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
    vtes=Vs-ites*Rpar;
    ptes=vtes.*ites;
    IVstruct(i).ibias=IVmeasure(i).ibias;
    IVstruct(i).vout=IVmeasure(i).vout;
    IVstruct(i).Rtes=vtes./ites;
    IVstruct(i).rtes=IVstruct(i).Rtes/Rn;
    IVstruct(i).ites=ites;
    IVstruct(i).vtes=vtes;
    
    if nargin==3
        IVstruct(i).ttes=(ptes./TES.K+Tbath.^(TES.n)).^(1/TES.n);
    end
    IVstruct(i).ptes=ptes;
    IVstruct(i).Tbath=Tbath;
end

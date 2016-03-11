function IVstruct=GetIVTES(Circuit,IVmeasure,varargin)
%Version de GetIVTES que devuelve estructura y acepta estructura de
%Circuito y Medida.
%Get ites and vtes from measured vout and ibias and values of Rf and Rsh.
%Rpar can be previously calculated or taken from slopes.


    Tbath=IVmeasure.Tbath;

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

ites=IVmeasure.voutc*invMin/(invMf*Rf);
Vs=(IVmeasure.ibias-ites)*Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
vtes=Vs-ites*Rpar;
ptes=vtes.*ites;
IVstruct.Rtes=vtes./ites;
IVstruct.rtes=IVstruct.Rtes/Rn;
IVstruct.ites=ites;
IVstruct.vtes=vtes;
if nargin==3
IVstruct.ttes=(ptes./TES.K+Tbath.^(TES.n)).^(1/TES.n);
end
IVstruct.ptes=ptes;

function Ites=V2I(vout,circuit)
%convert Vout values to Ites

invMin=circuit.invMin;%24.1;
invMf=circuit.invMf;%66;
Rf=circuit.Rf;
Ites=vout*invMin/(invMf*Rf);
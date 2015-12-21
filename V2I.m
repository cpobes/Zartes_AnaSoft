function Ites=V2I(vout,Rf)
%convert Vout values to Ites

invMs=24.1;
invMf=66;
Ites=vout*invMs/(invMf*Rf);
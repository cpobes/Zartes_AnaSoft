function [ites,vtes]=GetIVTES(vout,ibias)
%Get ites and vtes from measured vout and ibias and values of Rf and Rsh.
%Rpar can be previously calculated or taken from slopes.
Rf=3e3;
Rsh=2e-3;
IBS=1400e-6;VOS=10.87;%superconducting Slope.
IBN=2800e-6;VON=1.3;%normal Slope.
Rpar=((66.43*Rf/22)*IBS/VOS-1)*Rsh
RN=Rsh*(66.43*Rf/22)*IBN/VON-Rpar
ites=vout*22/(66.43*Rf);
Vs=(ibias*1e-6-ites)*Rsh;
vtes=Vs-ites*Rpar;

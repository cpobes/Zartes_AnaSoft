function [ites,vtes,ptes,rtes]=GetIVTES(vout,ibias,Rf)
%Get ites and vtes from measured vout and ibias and values of Rf and Rsh.
%Rpar can be previously calculated or taken from slopes.
%Rf=3e3;
Rsh=2e-3;
%IBS=1400e-6;VOS=10.87;%superconducting Slope.
%IBN=2800e-6;VON=1.3;%normal Slope.
%Rpar=((66.43*Rf/22)*IBS/VOS-1)*Rsh
%RN=Rsh*(66.43*Rf/22)*IBN/VON-Rpar
Rpar=.12e-3;Rn=25.0e-3;
invMf=66;invMin=24.1;
ites=vout*invMin/(invMf*Rf);
Vs=(ibias-ites)*Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
vtes=Vs-ites*Rpar;
ptes=vtes.*ites;
rtes=vtes./ites/Rn;
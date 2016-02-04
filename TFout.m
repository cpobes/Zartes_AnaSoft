function tfout=TFout(f,TFS,L)
%funcion de transferencia del circuito de salida deducida a partir de
%medidas en estado superconductor y L.

Rsh=2e-3;
Rf=1e4;%OJO!
invMf=66;
invMin=24.1;
%TES.
Rn=25e-3;
Rpar=0.11e-3;
Rth=Rsh+Rpar;

%IBOX
Rbox=1e4;
Lbox=2e-3;
Cbox=100e-12;
Rp=200;

Zp=Rp+1./(Cbox*2*pi*f*1i);
zbox=(Rbox*Zp)./(Rbox+Zp)+2*pi*f*1i*Lbox;

zs=Rth+1i*2*pi*f*L;
TFibox=1./(zbox.*(1+Rbox./Zp));
tfout = TFS .* zs ./ (Rf*(invMf/invMin)* TFibox*Rsh);


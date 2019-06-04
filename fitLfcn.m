function im_tfq=fitLfcn(L,f,circuit)
%%%función para ajustar la L del circuito a partir de la tfs y tfn.

Rsh=circuit.Rsh;
Rn=circuit.Rn;
Rpar=circuit.Rpar;
Rth=Rsh+Rpar;

zs=Rth+1i*2*pi*f*L;
tfq=1+Rn./zs;
im_tfq=imag(tfq);
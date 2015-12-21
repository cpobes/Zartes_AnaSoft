function Rpar=RparCalc(ms,Rf)
%calculo de la Rpar a partir de la pendiente experimental en estado
%superconductor (ms=Vout/Ibias)

invMf=66;
invMs=24.1;
Rsh=2e-3;
Rpar=(Rf*invMf/(ms*invMs)-1)*Rsh;
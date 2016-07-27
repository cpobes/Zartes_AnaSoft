function Rn=RnCalc(mN,mS,Rf)
%calcula la Rn a partir de las pendientes en estado normal y
%superconductor.
%OJO, la Rf del fichero S puede ser distinta de la del fichero N.

Rpar=RparCalc(mS,Rf)
Rsh=2e-3;
invMs=24.1;
invMf=66;
Rn=(Rsh*Rf*invMf/(mN*invMs)-Rsh-Rpar);


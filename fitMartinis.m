function Tc=fitMartinis(p,ds)%ds
%Creo una función a partir de 'martinis.m' con la forma adecuada para usar
%lsqcurvefit. Permite ajustar datos experimentales para sacar los valores
%de d_oro, 't' y 'Tc0' que mejor ajustan.
Tc=martinis(ds,p(1),p(2),p(3),1,p(4)); %añado p(4)=RRRs
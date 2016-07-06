function efwhm=energyres0(par)
%energy resolution zero aproximation Irwin ec 102

Kb=1.38e-23;
e=1.602e-19;

T0=par.T0;
C=par.C;
alfa=par.alfa;

n=3.2;
efwhm=2*sqrt(2*log(2))*sqrt(4*Kb*C*sqrt(n/2)/alfa)*T0/e;
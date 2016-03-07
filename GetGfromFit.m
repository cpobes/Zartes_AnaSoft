function param=GetGfromFit(fit)

param.n=fit.b;
param.K=-fit.a;
param.Tc=(fit.c/-fit.a)^(1/fit.b)
param.G=param.n*param.K*param.Tc^(param.n-1);


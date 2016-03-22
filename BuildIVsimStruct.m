function IVsim=BuildIVsimStruct(Ttes,Ites,TES)

Ic=TES.Ic;
Tc=TES.Tc;
Rn=TES.Rn;
IVsim.ites=Ites/Ic;
IVsim.ttes=Ttes/Tc;
%Vtes=Ib*Rsh-Ites*(Rsh+Rpar);
IVsim.rtes=FtesTI(IVsim.ttes,IVsim.ites);
IVsim.Rtes=IVsim.rtes*Rn;
IVsim.Vtes=Ites.*IVsim.Rtes;
IVsim.Ptes=Ites.*IVsim.Vtes;
IVsim.Ites=Ites;
IVsim.Ttes=Ttes;
function IVsim=BuildIVsimStruct(IV,TES)

Ic=TES.Ic;
Tc=TES.Tc;
Rn=TES.Rn;
IVsim.ites=IV.ites/Ic;
IVsim.ttes=IV.ttes/Tc;
%Vtes=Ib*Rsh-Ites*(Rsh+Rpar);
IVsim.rtes=FtesTI(IVsim.ttes,IVsim.ites);
IVsim.Rtes=IVsim.rtes*Rn;
IVsim.Vtes=IV.ites.*IVsim.Rtes;
IVsim.Ptes=IV.ites.*IVsim.Vtes;
IVsim.Ites=IV.ites;
IVsim.ttes=IV.ttes;%%%%
IVsim.Tbath=IV.Tbath;
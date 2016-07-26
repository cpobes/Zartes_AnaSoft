function OP=setTESOPfromIb(Ib,IV,p)
%set the TES operating point from Ibiaas and IV curves and fitted
%parameters p.

OP.r0=ppval(spline(IV.ibias,IV.rtes),Ib);
OP.V0=ppval(spline(IV.ibias,IV.vtes),Ib);
OP.I0=ppval(spline(IV.ibias,IV.ites),Ib);
OP.R0=OP.V0/OP.I0;
OP.P0=ppval(spline(IV.ibias,IV.ptes),Ib);
OP.Tbath=IV.Tbath;

OP.ai=ppval(spline([p.rp],[p.ai]),OP.r0);
OP.bi=ppval(spline([p.rp],[p.bi]),OP.r0);
OP.C=ppval(spline([p.rp],[p.C]),OP.r0);
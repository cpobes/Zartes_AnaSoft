function OP=setTESOPfromIb(Ib,IV,p)
%set the TES operating point from Ibias and IV curves and fitted
%parameters p.

[iaux,ii]=unique(IV.ibias,'stable');
OP.r0=ppval(spline(iaux,IV.rtes(ii)),Ib);
OP.V0=ppval(spline(iaux,IV.vtes(ii)),Ib);
OP.I0=ppval(spline(iaux,IV.ites(ii)),Ib);
OP.R0=OP.V0/OP.I0;
OP.P0=ppval(spline(iaux,IV.ptes(ii)),Ib);
OP.Tbath=IV.Tbath;

if length(p)>1
    OP.ai=ppval(spline([p.rp],[p.ai]),OP.r0);
    OP.bi=ppval(spline([p.rp],[p.bi]),OP.r0);
    OP.C=ppval(spline([p.rp],[p.C]),OP.r0);
else
    OP.ai=p.ai;
    OP.bi=p.bi;
    OP.C=p.C;
end
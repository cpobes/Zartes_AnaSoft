function problem=DefineSolverProblem(ib,tb,y0,TESparam,varargin)
if nargin==5
    options=varargin{1};
    problem.options=options;
end

    Rsh=TESparam.Rsh;Rpar=TESparam.Rpar;Rn=TESparam.Rn;
    Ic=TESparam.Ic;Tc=TESparam.Tc;
    n=TESparam.n;K=TESparam.K;
    
    %tb=Tb/Tc;ib=Ib/Ic;ub=tb^n;
    rp=Rpar/Rsh;rn=Rn/Rsh;
    A=(Tc^n*K)/(Ic^2*Rn);

f = @(y) NormalizedGeneralModelSteadyState(y,ib,tb,A,rp,rn,n);%y(1)=it,y(2)=tt.

problem.objective=f;
problem.x0=y0;
problem.solver='fsolve';


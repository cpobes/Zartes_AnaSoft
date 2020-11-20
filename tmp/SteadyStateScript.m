function IV=SteadyStateScript(varargin)
%%%Solver script. arg1:TES, arg2:circuit.

%%%TES info
if nargin==0
    Rsh=2e-3; RL=2.182e-3;
    n=3.067;K=1.769e-9;
else
    TES=varargin{1};
    circuit=varargin{2};
    Rsh=circuit.Rsh;Rpar=circuit.Rpar;
    RL=Rsh+Rpar;
    n=TES.n;K=TES.K;
end

TtesArray=0.12:-1e-4:0.06;
TbathArray=0.08:0.002:0.1;
I=0:1e-8:50e-6;

P=@(x,y) K*(x.^n-y.^n);
for k=1:length(TbathArray)
    Tbath=TbathArray(k);
    Ites=[];Rtes=[];Ibias=[];
for i=1:length(TtesArray)
    Ttes=TtesArray(i); 
    if Ttes<=TbathArray(k) break;end
    %P=K*(Ttes.^n-Tbath.^n);
    pw=P(Ttes,Tbath);
    F=@(I) I.^2.*GompertzRTI(Ttes,I)-pw;
    %Ites(i)=fsolve(F,5e-6);
    m=min(abs(F(I)));
    j=find(abs(F(I))==m);
    Ites(i)=I(j(1));
    Rtes(i)=GompertzRTI(Ttes,Ites(i));
    G=@(I) I.*(RL+GompertzRTI(Ttes,I));
    Ibias(i)=G(Ites(i))/Rsh;
end
IV(k).Ttes=TtesArray(1:length(Rtes));
IV(k).Ites=Ites;
IV(k).Rtes=Rtes;IV(k).Rtes(Ites==0)=0;%%%Cuando Ttes<Tb ->Ites=0
IV(k).Vtes=Rtes.*Ites;
IV(k).Ptes=Rtes.*Ites.^2;
IV(k).ibias=Ibias;
end

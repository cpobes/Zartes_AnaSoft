function [IVsim,xf]=simIV(Tb,varargin)

%scan parameters
%Imax=2e-3; %en mA %2e-3;
Imax=0.50e-3;
Imin=0;%0.5e-3;
Ib=linspace(Imin,Imax,500);
%relatstep=-1e-2;
%Ib=Imin:relatstep*Imax:Imax;
%Ib=Imax:-1e-2*Imax:Imin;

%parametros del TES
if nargin==1
    %default parameters
    Rsh=2e-3;Rpar=0.4e-3;%circuito
    n=3.2;K=1e-11;%membrana
    Rn=20e-3;Tc=0.1;Ic=1e-3;%TES
    TESparam.Rsh=Rsh;TESparam.Rpar=Rpar;TESparam.Rn=Rn;
    TESparam.Ic=Ic;TESparam.Tc=Tc;
else
    TESparam=varargin{1};
    Rsh=TESparam.Rsh;Rpar=TESparam.Rpar;Rn=TESparam.Rn;
    Ic=TESparam.Ic;Tc=TESparam.Tc;
    n=TESparam.n;K=TESparam.K;
    Circuitparam=varargin{2};
end

crs=Rsh/(Rsh+Rpar);crn=Rsh/(Rsh+Rpar+Rn);

%normalized parameters:
tb=Tb/Tc;ib=Ib/Ic;ub=tb^n;
%rp=Rpar/Rsh;rn=Rn/Rsh;%used only when calling NormalizedGMS directly.
%A=(Tc^n*K)/(Ic^2*Rn);

%options = optimset( 'TolFun', 1.0e-12, 'TolX',1.0e-12,'jacobian','off','algorithm','levenberg-marquardt','maxfunevals',500);%,'plotfcn',@optimplotfirstorderopt);
options = optimset( 'TolFun', 1.0e-15, 'TolX',1.0e-15,'jacobian','off','algorithm','levenberg-marquardt');
ites=zeros(1,length(Ib));
ttes=zeros(1,length(Ib));
for i=1:length(Ib)
     y0up=[crs*ib(i) tb];%%%!!!ub<->tb.
     it0=crn*ib(i);
     tt0=(((Ic*it0).^2*Rn*0.8/K+Tb^n).^(1/n))/Tc;
     y0down=[it0 tt0];%%%1.5^n<->1.5
     y0=y0down;%poner y0up para trazar subiendo.
        %TESparam.T0=Tb;TESparam.I0=cr*Ib(i);
        %cond=StabilityCheck(TESparam);
        %estab(i)=cond.stab;
     problem=DefineSolverProblem(ib(i),tb,y0,TESparam,options);  
    %f = @(y) NormalizedGeneralModelSteadyState(y,ib(i),tb,A,rp,rn,n); % function of dummy variable y
    %[out,fval,flag]=fsolve(f,y0,options);
    [out,~,flag]=fsolve(problem);
    %xf(i)=flag;
    ites(i)=out(1);
    ttes(i)=out(2);
    %ttes(i)=log(out(2))/n;
    %RtesTI(out(2),out(1))
end
%plot(Ttes,Ites)
%plot(Ib,Ites)

Ites=ites*Ic;
Ttes=ttes*Tc;
% TESparam.Rsh=Rsh;TESparam.Rpar=Rpar;TESparam.Rn=Rn;
% TESparam.Ic=Ic;TESparam.Tc=Tc;

showIVsims(Ttes,Ites,Ib,TESparam,Circuitparam)
IVsim=BuildIVsimStruct(Ttes,Ites,TESparam);


%Ttes(find(abs(Ttes>5)))=0;
%Ites(find(abs(Ites>.5)))=0;
%figure,plot3(Ttes,Ites,FtesTI(Ttes/0.1,Ites/1e-3),'.k')

%Ttes(find(Ttes>500))=0;
%plot3(Ttes,Ites,RtesTI(Ttes,Ites),'k')
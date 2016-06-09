function [ftes,varargout] = FtesTI(ttes,ites)
%version de RtesTI pero normalizada. Hacemos Rn=1. También pasamos la
%temperatura y corrientes normalizadas: ttes=T/Tc, ites=I/Ic.

%Definimos la norma modulo 'p'.
p=0.82;
%%%distancia_p. Esto en realidad supone tomar ya una forma para Ic(Ttes). 
%%%Si queremos probar otras expresiones, hay que modificar las definiciones de alfa y beta.
r=exp(log(exp(p*log(ttes))+exp(p*log(ites)))/p);

%BCS model for i(t)
%r=(ttes+ites.^(2/3)).^1; %i=(1-t)^(3/2) -> i^(2/3)+t=1 -> (i^(2/3)+t)^n=r.
%Se puede hacer n=1.

%%%available models:'power', 'erf', 'recta', 'ere', 'TFM'
model='TFM';%'recta';
if strcmp(model,'1')
%model1. %Dr=0.2;%0.01%for model 1 and model 2.
%Rtes=Rn./(1+exp(-(sqrt((Ttes/Tc).^2+(Ites/Ic).^2).^4-1)./Dr));
elseif strcmp(model,'2')
%model2
% r=sqrt(ttes.^2+ites.^2);
% r1=1-Dr;
% r2=1+Dr;
% ftes=((r-r1)/(r2-r1)).^1;%
% ftes(find(r<=r1))=0;
% ftes(find(r>=r2))=1;
% alfa=100;beta=0.96;
% varargout{1}=alfa;
% varargout{2}=beta;

elseif strcmp(model,'power')
%%%%%%%%%
%%%%%model3.R(T)=(T/Tc)^alfa.
%profiler notes. las operaciones '.^' son costosas. Reescribo para
%minimizarlas.
alfa=80;
%r=(ttes.^p+ites.^p).^(1/p);
%r=(ttes.^p+(1-ttes).^p).^(1/p);
%r=exp(log(exp(p*log(ttes))+exp(p*log(ites)))/p);%%%distancia_p
%r=exp(log(exp(p*log(ttes))+exp(3*log(1-ttes)))/p);
%ftes=r.^alfa;
lf=alfa*log(r);%esto acelera algo el codigo.
ftes=exp(lf);
ftes(r>1)=1;
%alfa y beta
lv1=log(alfa)+p*log(ttes./r);%esto acelera algo el codigo.
varargout{1}=exp(lv1);
%varargout{1}=alfa*(ttes./r).^p;
varargout{2}=alfa-varargout{1};
% varargout{1}=alfa*ttes.^p./(ites.^p+ttes.^p);%alfa
% varargout{2}=alfa*ites.^p./(ites.^p+ttes.^p);%beta

elseif strcmp(model,'erf')
%%%%Model 4. f='erf'
delta=0.01;
ftes=(erf((r-1)/delta)+1)/2;
alfar=(1/(delta))*r.*normpdf(r,1,delta/sqrt(2))./ftes;
varargout{1}=alfar.*(ttes./r).^p;
varargout{2}=alfar-varargout{1};

elseif strcmp(model,'recta')
    %%%modelo lineal en toda la transición.
    delta=0.007;
    ftes=(r-1)/delta+0.5;%%%R(Tc)=Rn/2.
    ftes(ftes<0)=0;
    ftes(ftes>1)=1;
    alfar=r./((r-1)+delta/2);
    varargout{1}=alfar.*(ttes./r).^p;
    varargout{2}=alfar-varargout{1};
    
elseif strcmp(model,'ere')
    %%%modelo expo+recta+expo.
    param=[0.1 0.95 0.01 0.9 1.05 0.01];
        T3=param(5)-param(6)*log(param(3)*param(4)/(param(6)*param(1)));
    ftes=param(1)*(1-heaviside(r-param(2))).*exp((r-param(2))/param(3))+...
        param(1)*(heaviside(r-param(2))-heaviside(r-param(5))).*(1+(r-param(2))/param(3))+...
        param(4)*heaviside(r-param(5)).*(1-exp(-(r-T3)/param(6)));
     alfar=r./((r-1)+0.01/2);%%%from 'recta'
    varargout{1}=alfar.*(ttes./r).^p;
    varargout{2}=alfar-varargout{1};
elseif strcmp(model,'TFM') %two fluid model
    ci=0.8;cr=1;
    ic=real((1-ttes).^1.5);%GL
    ftes=max(cr*(1-ci*ic./ites),0);
    varargout{1}=1.5*ci*cr*ites.*ttes.*(1-ttes).^.5./ftes;%ec 37 ullom review
    varargout{2}=cr./ftes-1; %ec 38 Ullom review
end


%para visualizar la superficie:
%Trange=[0:1e-3:1.5e-1];Irange=[0:1e-7:1e-4];
%[X,Y]=meshgrid(Trange,Irange);
%mesh(X,Y,RtesTI(X,Y))
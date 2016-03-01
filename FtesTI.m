function [ftes,varargout] = FtesTI(ttes,ites)
%version de RtesTI pero normalizada. Hacemos Rn=1.

%Dr=0.2;%0.01%for model 1 and model 2.

alfa=100;

%model1
%Rtes=Rn./(1+exp(-(sqrt((Ttes/Tc).^2+(Ites/Ic).^2).^4-1)./Dr));

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

%model3.R(T)=(T/Tc)^alfa.
%profiler notes. las operaciones '.^' son costosas. Reescribo para
%minimizarlas.
p=.8;
%r=(ttes.^p+ites.^p).^(1/p);
%r=(ttes.^p+(1-ttes).^p).^(1/p);
r=exp(log(exp(p*log(ttes))+exp(p*log(ites)))/p);%%%distancia_p
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

%para visualizar la superficie:
%Trange=[0:1e-3:1.5e-1];Irange=[0:1e-7:1e-4];
%[X,Y]=meshgrid(Trange,Irange);
%mesh(X,Y,RtesTI(X,Y))
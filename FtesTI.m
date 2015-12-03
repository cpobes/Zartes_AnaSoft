function [ftes,varargout] = FtesTI(ttes,ites)
%version de RtesTI pero normalizada. Hacemos Rn=1.

Dr=0.2;%0.01
alfa=50;

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
p=4;
r=(ttes.^p+ites.^p).^(1/p);
ftes=r.^alfa;
ftes(find(r>1))=1;
varargout{1}=alfa*ttes.^p./(ites.^p+ttes.^p);%alfa
varargout{2}=alfa*ites.^p./(ites.^p+ttes.^p);%beta

%para visualizar la superficie:
%Trange=[0:1e-3:1.5e-1];Irange=[0:1e-7:1e-4];
%[X,Y]=meshgrid(Trange,Irange);
%mesh(X,Y,RtesTI(X,Y))
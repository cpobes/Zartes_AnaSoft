function model=BuildThermalModel(varargin)
%%%%Construimos un modelo para el Fit de las Z(w).

if nargin==0
    model.nombre='default'
    model.function=@(p,f)([p(1)-(p(1)-p(2))./(1+((2*pi*f).^2)*(p(3).^2)) ...
      -abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
    
       %%%model.function=@(p,f)([ ... %%%%modelo para ajustar sólo Imag(Z).
      %%%-abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
    
      %w=2*pi*f;
    %D=(1+((2*pi*f).^2)*(p(3).^2));
    %rfz=p(1)-(p(1)-p(2))./D;%%%modelo de 1 bloque.
    %imz=-(p(1)-p(2))*w*p(3)./D;%%% modelo de 1 bloque.
    %imz=-abs(imz);
    
    model.description='p(1)=Zinf p(2)=Z0 p(3)=taueff'
    model.X0=[-1e-2 1e-2 1e-6];%%%p0=[Zinf Z0 tau0];%%%1TB
    model.LB=[-Inf -Inf 0];%%%lower bounds
    model.UB=[];%%%upper bounds    
end


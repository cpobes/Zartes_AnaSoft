function model=BuildThermalModel(varargin)
%%%%Construimos un modelo para el Fit de las Z(w).

opt=[];
for i=1:nargin
    varargin{i}
    if ischar(varargin{i}) name=varargin{i}, end
    if isstruct(varargin{i}) opt=varargin{i}, end
end

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
    model.noise=noisesim('irwin');%%%Ojo, noise model con default parameters
else
    switch name
        case 'default'
                model.nombre='default'
                model.function=@(p,f)([p(1)-(p(1)-p(2))./(1+((2*pi*f).^2)*(p(3).^2)) ...
                    -abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
                
                model.description='p(1)=Zinf p(2)=Z0 p(3)=taueff'
                model.X0=[-1e-2 1e-2 1e-6];%%%p0=[Zinf Z0 tau0];%%%1TB
                model.LB=[-Inf -Inf 0];%%%lower bounds
                model.UB=[];%%%upper bounds
                if isempty(opt)
                    model.noise=noisesim('irwin');
                else
                    model.noise=noisesim('irwin',opt.TES,opt.OP,opt.circuit);
                end
            
        case 'ImZ'
            model.nombre='ImZ'
            model.function=@(p,f)([ ... %%%%modelo para ajustar sólo Imag(Z).
                -abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
            model.description='p(1)=Zinf p(2)=Z0 p(3)=taueff'
            model.X0=[-1e-2 1e-2 1e-6];%%%p0=[Zinf Z0 tau0];%%%1TB
            model.LB=[-Inf -Inf 0];%%%lower bounds
            model.UB=[];%%%upper bounds
                if isempty(opt)
                    model.noise=noisesim('irwin');
                else
                    model.noise=noisesim('irwin',opt.TES,opt.OP,opt.circuit);
                end
        case '2TB_hanging'
            model.nombre='2TB_hanging'
            %fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;
            model.function=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
                 imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
            model.description='p=[Zinf Z0 tau_I d1 tau1]; *tau_I=Ctes/(Gtes+G)(LH-1),  *d=Gtes/(Gtes+G)(LH-1), tau1=CA/Gtes';
            model.X0=[-1e-2 1e-2 1/(2*pi*1e4) 100 1/(2*pi*1e2)];
            model.LB=[-Inf -Inf 0 0 0];
            model.UB=[Inf Inf 1 1e5 1];
                if isempty(opt)
                    model.noise=noisesim('irwin');%%%!!!ojo, noise model con default options
                else
                    model.noise=noisesim('2TB_hanging',opt.TES,opt.OP,opt.circuit);
                end
        case '2TB_intermediate'
            model.nombre='2TB_intermediate'
            %fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;
            model.function=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
                 imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
            model.description='p=[Zinf Z0 tau_I d1 tau1]; *tau_I=Ctes/(Gtes+G)(LH-1),  *d=Gtes/(Gtes+G)(LH-1), tau1=CA/Gtes';
            model.X0=[-1e-2 1e-2 1/(2*pi*1e4) 0.03 1/(2*pi*1e2)];
            model.LB=[-Inf -Inf 0 0 0];
            model.UB=[Inf Inf 1 1e5 1];
                if isempty(opt)
                    model.noise=noisesim('irwin');%%%!!!ojo, noise model con default options
                else
                    model.noise=noisesim('2TB_intermediate',opt.TES,opt.OP,opt.circuit);
                end
    end
end


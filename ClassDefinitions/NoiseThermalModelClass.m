classdef NoiseThermalModelClass < handle
    
    properties
        Kb=1.38e-23;
        %%%Basic Properties
        fname='1TB';
        fNumberOfBlocks=1;
        fNumberOfLinks=1;
        fLinksList={'TES-B'}; %%%Definición del modelo de bloques a través de la lista con el tipo de links
        %%%opciones: 'TES-B', 'TES-H', 'TES-I', 'I-B'. Todos los modelos se
        %%%construyen como combinaciones de ellos.
        fNumberOfComponents=3;%%Numero de componentes de ruido sin contar el circuitnoise.
        fOperatingPoint=[];
        fCircuit=[];
        fTES=[];
        fParameters=[];
        fZtesHandler=@(x)x;
        fsIHandler=@(x)x;
        fRshNoiseHandler=@(x)x;
        fJohnsonNoiseHandler=@(x)x;
        fPhononNoiseHandlerArray=[];
        fTotalCurrentNoiseModel=@(x)x;
        %%%boolean parameters
        boolUseExperimentalZtes=0;
        boolUseExperimentalCircuitNoise=0;
        boolAddMjohnson=1;
        boolAddMphononArray=[1 1 1];
        
        %%%Plotting Properties
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=NoiseThermalModelClass(PARAMETERS,varargin)
            %%%alteramos el orden respecto a BuildThermalModel() function.
            %%%Obligamos a pasar OP, TES y circuit, que son necesarios, y
            %%%opcionalmente el nombre del modelo.
            nargin
            if nargin==2
                obj.fname=varargin{1};
                obj.ParseModelName(varargin{1});%%%Funcion para actualizar el fLinksList
            end
            obj.fOperatingPoint=PARAMETERS.OP;%%%Si definimos OP como una clase habrá que cambiar esto.
            obj.fCircuit=PARAMETERS.circuit;
            obj.fTES=PARAMETERS.TES;
            s=numel(PARAMETERS.OP.parray);
            obj.fNumberOfBlocks=(s-1)/2;
            obj.fNumberOfLinks=numel(obj.fLinksList);
            obj.fNumberOfComponents=obj.fNumberOfLinks+2;           
            obj.BuildZtesfunction();
            obj.BuildsIfunction();
            obj.BuildRshNoisefunction();
            obj.BuildJohnsonNoisefunction();
            obj.BuildPhononNoiseComponents();
            obj.GetTotalCurrentNoise()
        end
        function list=ParseModelName(obj,modelname)
            switch modelname
                case {'default' 'irwin'}
                    list={'TES-B'};
                case '2TB_hanging'
                    list={'TES-B' 'TES-H'};
                case '2TB_intermediate'
                    list={'TES-I' 'I-B'};
                case '2TB_parallel'
                    list={'TES-B' 'TES-I' 'I-B'};
            end
            obj.fLinksList=list;
        end
        function fZtesHandler=BuildZtesfunction(obj)
            if obj.fNumberOfBlocks==1
                fH=@(p,f)(p(1)+(p(2)-p(1)).*(1-1i*(2*pi*f)*p(3)).^-1);
            elseif obj.fNumberOfBlocks==2
                fH=@(p,f)(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1);
            elseif obj.fNumberOfBlocks>2%%%Generalizar para cualquier p size.
                warning('modelo no implementado')
            end
            p0=obj.fOperatingPoint.parray;
            fZtesHandler=@(f)fH(p0,f);
            obj.fZtesHandler=fZtesHandler;
        end
        function ZcircuitHandler=BuildZcircuitHandler(obj)
            RL=obj.fCircuit.Rsh+obj.fCircuit.Rpar;
            L=obj.fCircuit.L;
            if isfield(obj.fOperatingPoint,'ztes')&& obj.boolUseExperimentalZtes
                OP=obj.fOperatingPoint;
                ztes=@(f)interp1(OP.ztes.freqs,OP.ztes.data,f);
            else
                ztes=obj.BuildZtesfunction();
            end
            ZcircuitHandler=@(f)ztes(f)+RL+1i*2*pi*f*L;
        end
        function fsIHandler=BuildsIfunction(obj)
            zcirc=obj.BuildZcircuitHandler();
            ztes=obj.BuildZtesfunction();
            R0=obj.fOperatingPoint.R0;
            bI=obj.fOperatingPoint.bi;
            I0=obj.fOperatingPoint.I0;
            V0=I0*R0;
            fsIHandler=@(f)(ztes(f)-R0*(1+bI))./(zcirc(f)*V0*(2+bI));
            obj.fsIHandler=fsIHandler;
        end
        
        function fRshNoiseHandler=BuildRshNoisefunction(obj)
            Kb=obj.Kb;
            RL=obj.fCircuit.Rsh+obj.fCircuit.Rpar;
            zcirc=obj.BuildZcircuitHandler();
            Ts=obj.fOperatingPoint.Tbath;
            fRshNoiseHandler=@(f)4*Kb*Ts*RL./abs(zcirc(f)).^2;%%%johnson en la shunt
            obj.fRshNoiseHandler=fRshNoiseHandler;
        end
        function fJohnsonNoiseHandler=BuildJohnsonNoisefunction(obj)     
            Kb=obj.Kb;
            zcirc=obj.BuildZcircuitHandler();
            ztes=obj.BuildZtesfunction();
            T0=obj.fOperatingPoint.T0;
            R0=obj.fOperatingPoint.R0;
            bI=obj.fOperatingPoint.bi;
            fJohnsonNoiseHandler=@(f)(4*Kb*T0*R0*(1+2*bI)).*abs(ztes(f)+R0).^2./(R0^2*(2+bI).^2*abs(zcirc(f)).^2);%%%ruido johnson
            obj.fJohnsonNoiseHandler=fJohnsonNoiseHandler;
        end
        function fPhononNoiseHandlerArray=BuildPhononNoiseComponents(obj)
            Kb=obj.Kb;
            for i=1:obj.fNumberOfComponents-2
                fPhononNoiseHandlerArray{i}=@(f)0;
            end
            obj.fPhononNoiseHandlerArray=fPhononNoiseHandlerArray;
        end
        
        function fTotalCurrentNoiseHandler=GetTotalCurrentNoise(obj)
%             if obj.boolAddMjohnson
%                 obj.fOperatingPoint.P
%                 Mjo=obj.fOperatingPoint.M;
%             else
%                 Mjo=0;
%             end
            ssh=obj.BuildRshNoisefunction();
            stes=obj.BuildJohnsonNoisefunction();
            sjo=@(f,Mjo)ssh(f)+stes(f)*(1+Mjo^2);%%%Definimos el Mjo tambien como parametro para poder hacer fit.
            sphSum=@(f,Mph)0;%%%Initialization
            %%%Falta implementar bien las componenetes phonon. ya no da
            %%%error pero salen mal.
            for i=1:obj.fNumberOfComponents-2
%                 if obj.boolAddMphononArray(i)
%                     Mph(i)=obj.fOperatingPoint.Mph(i);
%                 else
%                     Mph(i)=0;
%                 end
                
                sph=obj.fPhononNoiseHandlerArray{i};
                sphSum=@(f,Mph)sphSum(f,Mph)+sph(f)*(1+Mph^2);%%%%!
            end
            stot=@(f,Mjo,Mph) sjo(f,Mjo)+sphSum(f,Mph);
            if isfield(obj.fCircuit,'circuitnoise') && obj.boolUseExperimentalCircuitNoise
                circuitnoise=@(f)interp1(obj.fCircuit.circuitnoise(:,1),obj.fCircuit.circuitnoise(:,2),f);
            else
                circuitnoise=@(f)obj.fCircuit.squid;
            end
            fTotalCurrentNoiseHandler=@(f,Mjo,Mph)sqrt(stot(f,Mjo,Mph)+circuitnoise(f).^2);
            obj.fTotalCurrentNoiseModel=fTotalCurrentNoiseHandler;
        end
        
        function P2=BuildGeneralLinkPowerSpectrumNoise(obj,T0,T1,G0,n0)
            %%%Todos los ruidos phonon parten de una expresión general para
            %%%el espectro de potencias del ruido términco entre dos
            %%%bloques a temperatura T0 y T1. La expresión genreal es la
            %%%(18) del artículo de Maasilta, que desarrollando, y
            %%%asumiendo que el mecanismo de conducción es el mismo en los
            %%%dos extremos del link térmico, se puede convertir en la
            %%%expresión phonon de 1TB. Pero según se pasen unos valores u
            %%%otros de Ts, G y n, esta función general se puede usar para
            %%%todos los modelos. Después se combina con la |sI| y con una
            %%%parte dependiente de 'w' y del link concreto, que es la que
            %%%hay que particularizar según el modelo. Esto va a ser válido
            %%%también para los dos modelos 3TB que considera Maasilta, el
            %%%2H y el IH.
            
            t=T1/T0;
            F=(1+t^(n0+1))/2;
            P2=@(f) 4*obj.Kb*T0^2*G0*F; %%%Notar que este término es constante en frecuencia, la dependencia en freq la dan los otros términos.
            %%%Devolvemos un handle a funcion aunque sea constante para
            %%%usarla en combinación con el resto de términos.
        end
        function H=BuildGeneral_H_Term(obj,tau,a,b)
            %%%Este término es general para construir cualquier
            %%%contribución phonon. El ruido en corriente phonon específico
            %%%será sph=P2*|sI(w)|^2*H(w), donde el H(w) hay que
            %%%construirlo de manera específica para cada modelo a partir
            %%%de esta función, según los valores de a y b.
            
            H=@(f) (a+b*(2*pi*f*tau).^2)./(1+(2*pi*f*tau).^2);
            %%%Por ejemplo, el H para 1TB es B_H_Term(tau,1,1). Devolvemos
            %%%de nuevo handle a función de la frecuencia.
        end
        function H=GetModelDependent_H_Term(obj,model,varargin)
            %%%Esta función puede devolver el término H específico para
            %%%cada Link en función del par de bloques a considerar. Pero
            %%%faltará combinar según el modelo los distintos términos.
            
            %%%Hay que llamarla con opt.tau y opt.g2, aunque para TES-B no
            %%%hace falta.
            
            %%%Hasta 3TB (al menos los modelos considerados por Maasilta,
            %%%existen sólo 4 tipos distintos de Link, que podemos definir
            %%% (usando D=(1+(w*tau)^2) como:
            %%%-- TES-Baño: H=1
            %%%-- TES-Hanging: H=(wtau)^2/D(w)
            %%%-- TES-Intermediate: H=(g2+(w*tau)^2)/D
            %%%--Intermediate-Baño: H=g2*1/D
            %%% donde g2 es un cociente adimensional de conductancias al
            %%% cuadrado dependiennte del modelo.
            
            %%%Recordar que llamamos H_Tetm(tau,a,b)
            switch model
                case 'TES-B'
                    H=obj.BuildGeneral_H_Term(0,1,1);
                    %H=@(f)1
                case 'TES-H'
                    tau=varargin{1}.tau;
                    H=obj.BuildGeneral_H_Term(tau,0,1);
                case 'TES-I'
                    tau=varargin{1}.tau;
                    g2=varargin{1}.g2;
                    H=obj.BuildGeneral_H_Term(tau,g2,1);
                case 'I-B'
                    tau=varargin{1}.tau;
                    g2=varargin{1}.g2;
                    H=obj.BuildGeneral_H_Term(tau,g2,0);
            end
        end
    end
end
    
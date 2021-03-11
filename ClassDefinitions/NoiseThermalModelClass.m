classdef NoiseThermalModelClass < handle
    
    properties
        Kb=1.38e-23;
        %%%Basic Properties
        fname='1TB';
        fNumberOfBlocks=1;
        fNumberOfComponents=3;
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
            if nargin==2
                obj.fname=varargin{1};
            end
            obj.fOperatingPoint=PARAMETERS.OP;%%%Si definimos OP como una clase habrá que cambiar esto.
            obj.fCircuit=PARAMETERS.circuit;
            obj.fTES=PARAMETERS.TES;
            s=numel(PARAMETERS.OP.parray);
            obj.fNumberOfBlocks=(s-1)/2;
            obj.fNumberOfComponents=obj.fNumberOfBlocks+2;
            if strcmp(obj.fname,'2TB_parallel') obj.fNumberOfComponents=5;end
            obj.BuildZtesfunction();
            obj.BuildsIfunction();
            obj.BuildRshNoisefunction();
            obj.BuildJohnsonNoisefunction();
            obj.BuildPhononNoiseComponents();
            obj.GetTotalCurrentNoise()
        end
        function fZtesHandler=BuildZtesfunction(obj)
            if obj.fNumberOfBlocks==1
                fH=@(p,f)(p(1)+(p(2)-p(1)).*(1-1i*(2*pi*f)*p(3)).^-1);
            elseif obj.fNumberOfBlocks==2
                fH=@(p,f)(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1);
            elseif obj.fNumberOfBlocks>2
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
                fPhononNoiseHandlerArray{i}=@(f)f;
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
            for i=1:0%obj.fNumberOfComponents-2
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
    end
end
    
classdef NoiseDataClass < handle
    
    properties
        path='';
        file='';
        freqs=logspace(0,6,1000);
        rawVoltage=[];
        CurrentNoise=[];
        NEP=[];%%%El NEP requiere de la sI y por tanto de un modelo.
        fOperatingPoint;
        fTES;
        fCircuit;
        FilteredVoltageData=[];
        NoiseModelClass=[];
        
        %filter options
        filter_options=[];%.method='movingMean'; %a definir en la funcion filterNoise().
        %filter_options.wmed=20;
        %filter_options.wmin=5;
        
        %handles
        fCurrentDataHandle=[];
        fNEPHandle=[];
        
        %plotoptions
        plottype='current';%options: 'current', 'nep'
        units='pA';%options: 'pA, fW, A, W' /raizHz.
        boolcomponents=0;
        boolShowFilteredData=1;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=NoiseDataClass(filename,PARAMETERS)
            circuit=PARAMETERS.circuit;
            if isempty(filename)
                [noise,file,path]=loadnoise(0);
            else
                [noise,file,path]=loadnoise(0,filename);
            end            
            noise=noise{1};
            obj.path=path;
            obj.file=file;
            obj.freqs=noise(:,1);
            obj.rawVoltage=noise(:,2);
            obj.CurrentNoise=V2I(noise(:,2),circuit);
            obj.fCurrentDataHandle=@(f) interp1(obj.freqs,obj.CurrentNoise,f);
            obj.FilteredVoltageData=obj.rawVoltage;%No default filtering.
            obj.fCircuit=circuit;
            obj.fTES=PARAMETERS.TES;
            obj.fOperatingPoint=PARAMETERS.OP;
            
            obj.filter_options.method='movingmean';
            obj.filter_options.wmed=20;
            obj.filter_options.wmin=5;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Filter Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function filtered_data=FilterNoise(obj,varargin)
            if nargin==1
                method=obj.filter_options.method;
                wmed=obj.filter_options.wmed;
                wmin=obj.filter_options.wmin;
            else
                optdata=varargin{1};
                method=optdata.method;
                wmed=optdata.wmed;
                wmin=optdata.wmin;
            end
            filtopt.model=method;
            filtopt.wmed=wmed;
            filtopt.wmin=wmin;
            filtered_data=filterNoise(obj.rawVoltage,filtopt);
            obj.FilteredVoltageData=filtered_data;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Plot Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Plot(obj)
            scale=1;
            if strcmp(obj.units,'pA')
                scale=1e12;
            end
            loglog(obj.freqs,scale*obj.CurrentNoise,'.-')
            grid on
            if obj.boolShowFilteredData
                hold on
                %obj.FilterNoise()
                loglog(obj.freqs,scale*V2I(obj.FilteredVoltageData,obj.fCircuit),'.-k');
            end
        end
        
        %%%%%%%%%%%%%%%
        %%%Setters
        %%%%%%%%%%%%%%%
        function  SetNoiseModel(obj,model)
            parameters.OP=obj.fOperatingPoint;
            parameters.TES=obj.fTES;
            parameters.circuit=obj.fCircuit;
            obj.NoiseModelClass=NoiseThermalModelClass(parameters,model);
            if isfield(obj.fCircuit,'circuitnoise')
                circuitnoise=obj.fCircuit.circuitnoise;
            else
                circuitnoise=3e-12;
            end
%             ss=obj.CurrentNoise.^2-circuitnoise.^2;
%             sI=obj.NoiseModelClass.fsIHandel(obj.freqs);
%             obj.NEP=sqrt(ss)./abs(sI);
            
            if isfield(obj.fCircuit.circuitnoiseHandle)
                cnHandle=obj.fCircuit.circuitnoiseHandle;
            elseif length(circuitnoise==1)
                cnHandle=@(f) circuitnoise;
            else
                cnHandle=@(f) interp1(obj.freqs,circuitnoise,f);
            end
            obj.fNEPHandlendle=@(f) sqrt(obj.fCurrentDataHandle(f).^2-cnHandle(f).^2)./abs(obj.NoiseModelClass.fsIHandel(f));
            obj.NEP=obj.fNEPHandle(obj.freqs);
        end
        %%%%%%%%%%%%%%%
        %%%Calculations
        %%%%%%%%%%%%%%%
        function Res=GetBaselineResolution(obj)
            %%%%%%%               
            Res=2.35/sqrt(trapz(f,1./obj.NEP.^2))/2/1.609e-19;
        end
        
    end %%%end methods
end
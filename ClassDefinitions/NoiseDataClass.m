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
        fRawVoltageDataHandle=[];
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
            current=obj.CurrentNoise;
            obj.fRawVoltageDataHandle=@(f) interp1(noise(:,1),noise(:,2),f);
            %obj.fCurrentDataHandle=@(f) interp1(obj.freqs,obj.CurrentNoise,f);
            obj.fCurrentDataHandle=@(f) interp1(noise(:,1),current,f);
            obj.FilteredVoltageData=obj.rawVoltage;%No default filtering.
            obj.fCircuit=circuit;
            obj.fTES=PARAMETERS.TES;
            obj.fOperatingPoint=PARAMETERS.OP;
            
            obj.filter_options.model='movingMean';
            obj.filter_options.wmed=20;
            obj.filter_options.wmin=5;
            obj.filter_options.thr=25;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Filter Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function filtered_data=FilterNoise(obj,varargin)
            if nargin==1
                %%%method=obj.filter_options.method;
                %%%wmed=obj.filter_options.wmed;
                %%%wmin=obj.filter_options.wmin;
                filtopt=obj.filter_options;
            else
                %optdata=varargin{1};
                %method=optdata.method;
                %wmed=optdata.wmed;
                %wmin=optdata.wmin;
                filtopt=varargin{1};
            end
%             filtopt.model=method;
%             filtopt.wmed=wmed;
%             filtopt.wmin=wmin;
            rawData2filter=obj.fRawVoltageDataHandle(obj.freqs);%%%
            filtered_data=filterNoise(rawData2filter,filtopt);
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
            loglog(obj.freqs,scale*obj.fCurrentDataHandle(obj.freqs),'.-')
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
            
            if isfield(obj.fCircuit,'circuitnoiseHandle')
                cnHandle=obj.fCircuit.circuitnoiseHandle;
            elseif length(circuitnoise==1)
                cnHandle=@(f) circuitnoise;
            else
                cnHandle=@(f) interp1(obj.freqs,circuitnoise,f);
            end
            obj.fNEPHandle=@(f) sqrt(obj.fCurrentDataHandle(f).^2-cnHandle(f).^2)./abs(obj.NoiseModelClass.fsIHandler(f));
            obj.NEP=obj.fNEPHandle(obj.freqs);
        end
        %%%%%%%%%%%%%%%
        %%%Calculations
        %%%%%%%%%%%%%%%
        function Res=GetPartialBaselineResolution(obj,fmax)
            %%%Ojo, para fmax>1e4 da warning de posible falta de precisión.
            %%%ejecuto un for para ver la evolucióny tarda bastante. con
            %%%fmax>1e6 da NaN.
            if ~isempty(obj.fNEPHandle)
                fh=@(f) 1./obj.fNEPHandle(f).^2;
                auxint=integral(fh,0,fmax);
                Res=sqrt(2*log(2)./auxint)/1.609e-19;
            else
                ind=find(obj.freqs<fmax);
                Res=sqrt(2*log(2))/sqrt(trapz(obj.freqs(ind),1./obj.NEP(ind).^2))/1.609e-19;
            end
            
        end
        function Res=GetBaselineResolution(obj)
            %%%%%%%               
            Res=sqrt(2*log(2))/sqrt(trapz(obj.freqs,1./obj.NEP.^2))/1.609e-19;
        end
        
    end %%%end methods
end
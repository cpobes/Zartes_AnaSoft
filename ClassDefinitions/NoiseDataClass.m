classdef NoiseDataClass < handle
    
    properties
        path='';
        file='';
        freqs=logspace(0,6,1000);
        rawVoltage=[];
        CurrentNoise=[];
        %NEP=[];%%%El NEP requiere de la sI y por tanto de un modelo.
        circuit;
        FilteredVoltageData=[];
        
        %filter options
        filter_method='movingMean'; %a de finir en la funcion filterNoise().
        
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
        function obj=NoiseDataClass(filename,circuit)
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
            %obj.NEP;
            obj.circuit=circuit;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Filter Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function filtered_data=FilterNoise(obj,varargin)
            if nargin==1
                method=obj.filter_method;
            else
                method=varargin{1};
            end
            filtopt.model=method;
            filtopt.wmed=5;%%%
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
                obj.FilterNoise()
                loglog(obj.freqs,scale*V2I(obj.FilteredVoltageData,obj.circuit),'.-k');
            end
        end
    end %%%end methods
end
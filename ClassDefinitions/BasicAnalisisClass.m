classdef BasicAnalisisClass
    properties
        structure=[];
        NoisePlotOptions=BuildNoiseOptions;
    end
    methods
        function obj=BasicAnalisisClass(TES_data_str)
            obj.structure=TES_data_str;
        end
        function plotParameter(obj,Temp,x_str,y_str)
            [~,mP]=GetTbathIndex(Temp,obj.structure);
            plotParamTES(obj.structure.P(mP),x_str,y_str)
        end
        function plotZs(obj,Temp,rps)
            plotZ_Tb_Rp(obj.structure,rps,Temp)
        end
        function plotNoises(obj,Temp,rps)
            plotnoiseTbathRp(obj.structure,Temp,rps,obj.NoisePlotOptions)
        end
    end
end
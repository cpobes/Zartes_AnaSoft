classdef ModelDependetOperatingPointClass < GeneralDynamicOperatingPointClass
    properties
        fai=0; %%%Alfa
        fCtes=0;
        ftau0=0;
        fL0=0;
        fCarray=[];%%%Array con las Cs de los bloques.
        fLinksList={};
        fGarray=[];
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=ModelDependetOperatingPointClass(OPstruct,SETUP,PARRAY,modelname)
            obj@GeneralDynamicOperatingPointClass(OPstruct,SETUP,PARRAY);
            ParseModelName(obj,modelname);%%%Actualizamos la lista de links. Redundante.
            switch modelname
                case {'irwin' 'default'}
                    obj.fL0=obj.fLfit;
                    obj.fai=obj.fL0*obj.fG0*obj.fT0./obj.fP0;
                    obj.ftau0=obj.fTaueff*(obj.fL0-1);
                    obj.fCtes=obj.ftau0./obj.fG0;
                case '2TB_hanging'
                case '2TB_intermediate'
                case '2TB_parrallel'
                case '3TB_2H'
                case '3TB_IH'
            end
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
        end%%%Función copiada de NoiseThermalModel. Redundante?
    end

end
classdef BasicTESGeometryClass < handle
    %%%Wrapper Class para encapsular la estructura devuelta por AnalizaRun
    %%%junto con funciones para acceder a la estructura, pintar los datos y
    %%%reanalizarlos.
    properties
        TESname=[];
        structure=[];%%%Estructura con los datos de la bicapa, absorbente y membrana.
        Ctes=0;
        Cabs=0;
        Ctot=0;
    end
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=BasicTESGeometryClass(TES_geo_str)
            obj.TESname=inputname(1);
            obj.structure=TES_geo_str;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Get functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Ctot=GetCtotal(obj)
            struct=obj.structure;
            Ctes=0;Cabs=0;
            if isfield(struct,'bilayer')
                bilayer=struct.bilayer;
                Ctes=CthCalc(bilayer);
                obj.Ctes=Ctes;
            end
            if isfield(struct,'absorber')
                absorber=struct.absorber;
                Cabs=CthCalc(absorber);
                %Cabs=CvDesign(absorber.Tc,absorber);%Ojo, CvDesign
                %necesita otro formato.
                obj.Cabs=Cabs;
            end
            Ctot=Ctes+Cabs;
            obj.Ctot=Ctot;
        end
    end
end
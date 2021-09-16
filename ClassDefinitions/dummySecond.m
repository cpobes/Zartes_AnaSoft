classdef dummySecond < dummyBasic & dummycircuit & handle
    properties
        f2;
        %fRsh;
    end
    methods
        function obj=dummySecond(varargin)
            %obj@dummycircuit(varargin{1});
            obj.f2=2;
            obj.fRsh='prueba';
        end
        function Update(obj,Class)
            if isa(Class,'dummycircuit')
                Update@dummycircuit(obj,Class);
            end
        end
    end
end
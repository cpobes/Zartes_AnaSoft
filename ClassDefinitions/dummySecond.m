classdef dummySecond < dummyBasic & dummycircuit & handle
    properties
        f2;
    end
    methods
        function obj=dummySecond(varargin)
            %obj@dummycircuit(varargin{1});
            obj.f2=2;
        end
        function Update(obj,Class)
            if isa(Class,'dummycircuit')
                Update@dummycircuit(obj,Class);
            end
        end
    end
end
classdef dummycircuit < handle
    properties
        fRsh
        fRf
    end
    methods
        function obj=dummycircuit(varargin)
            obj.fRsh=2e-3;
            obj.fRf=10e-3;
            if nargin==1
                class=varargin{1};
                obj.fRsh=class.fRsh;
                obj.fRf=class.fRf;
            end
        end
        function Update(obj,Class)
            if isa(Class,'dummycircuit')
                obj.fRsh=Class.fRsh;
                obj.fRf=Class.fRf;
            end
        end
    end
end
function [SmoothData,varargout]=movingMean(data,w,varargin)
%%%%Funci�n para aplicar el filtrado de media m�vil a unos datos pero
%%%%sin afectar al inicio y final de los mismos, reduciendo el tama�o de la
%%%%ventana en los extremos.

D=ceil(w-1/2);
L=length(data);
if nargin==2
    THR=25;%%%porcentaje de umbral.
else
    THR=varargin{1};
end
for i=1:L
    Mi=min([D,i-1,L-i]);
    %SmoothData(i)=mean(data(i-Mi:i+Mi));
    SmoothData(i)=trimmean(data(i-Mi:i+Mi),THR);%%%media descartando outliers.
    st(i)=std(data(i-Mi:i+Mi));
end
varargout{1}=st;
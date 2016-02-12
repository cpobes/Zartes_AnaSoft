function varargout=plotZtes(TFm,TFs,f,L,varargin)
%plot Ztes from measured TF and superconducting TF.


Rsh=2e-3;
Rpar=.12e-3;
Rth=Rsh+Rpar;
%L=78e-7;
if nargin>4
    ind=varargin{1};
    Ztes=(TFs(1:ind)./TFm(1:ind)-1).*(Rth+1i*2*pi*L*f(1:ind));
else
    Ztes=(TFs./TFm-1).*(Rth+1i*2*pi*L*f);
end
varargout{1}=Ztes;
plot(Ztes,'r')
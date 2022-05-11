function [psd,freq]=PSD(data,varargin)
%%%calcula el espectrum power de una serie temporal data conteniendo tiempo
%%%y valores

t=data(:,1);
x=data(:,2);
SF=1./mean(diff(t));%
N=length(x);
ft=fft(x);ft=ft(1:ceil(N/2));
psd=abs(ft).^2/SF/N;
psd(2:end-1)=2*psd(2:end-1);
freq=1:SF/N:SF/2;%%%!!!
if nargin==2
    opt=varargin{1};
    if isnumeric(opt) && opt
        freq=[freq freq(end)+SF/N:SF/N:2*freq(end)];
        psd=[psd(:); flip(psd(1:end-1))];
    end
end

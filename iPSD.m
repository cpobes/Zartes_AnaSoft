function [signal,time]=iPSD(psd,freq)
%%%intento de sacar la f(t) a partir del PSD.
L=length(freq);
DF=freq(2)-freq(1);
totL=2*(L-1);
SF=DF*totL;
extendedPSD=zeros(1,totL);
extendedPhase=zeros(1,totL);
extendedPSD(1:L)=psd;
extendedPSD(2:L-1)=extendedPSD(2:L-1)/2;%%%En PSD se multiplican por 2 esas frecuencias.
extendedPhase(1:L)=2*pi*rand(1,L);%%%Seleccionamos aleatoriamente la fase entre 0 y 2pi. Sirve tb entre 0 y pi.
for i=1:L-2
    extendedPSD(L+i)=extendedPSD(L-i);
    extendedPhase(L+i)=-extendedPhase(L-i);
end
fftmag=sqrt(extendedPSD*SF*totL);
extendedPhase(1)=pi; %%%El primer elemento da el nivel DC, pero al haber tomado valor absoluto, hay una indeterminaci�n en el signo del DC.
%%%La fase ser� '0' si DC>0 y 'pi' si DC<0.
fftfull=fftmag.*(cos(extendedPhase)+1i*sin(extendedPhase));
signal=real(ifft(fftfull));
time=(0:2*L-3)/DF/numel(signal);
%%%%El resultado es bastante satisfactorio, da una se�al f(t) similar al
%%%%ruido real del que se ha obtenido la PSD, pero la traza es sim�trica
%%%%respecto del punto medio. Es normal? Era pq hac�a que la fase de la
%%%%segunda parte fuese igual que la de la primera, pero en una fft esa
%%%%fase tiene un cambio de signo.
%%%Para pulsos de RX obviamente no
%%%%sirve, se ha perdido la informaci�n de fase.
%%%En cualquier caso, con esto se puede intentar simular ruidos m�s
%%%realistas para optimizar los estimadores de energ�a. 
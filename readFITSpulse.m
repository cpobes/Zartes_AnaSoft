function pulso=readFITSpulse(file,index,varargin)
%%%funci�n para leer un pulso de un fichero FITS
%%% suponemos que est�n en la bloque 2.
%%% 17Dic2021 incluimos varargin para pasar el DataUnit y leemos SR y RL
%%% para devolver tambien los times en primera columna.

import matlab.io.*

fptr=fits.openFile(file);

if nargin==2
    DataUnit=2;
else
    DataUnit=varargin{1};
end

fits.movAbsHDU(fptr,DataUnit);
SR=str2num(fits.readKey(fptr,'SR'));
RL=str2num(fits.readKey(fptr,'RL'));
time=(1:RL)/SR;
ydata=fits.readCol(fptr,1,index,1)';

pulso=[time(:) ydata];
fits.closeFile(fptr);
function ydata=readFITSpulse(file,index)
%%%funci�n para leer un pulso de un fichero FITS
%%% suponemos que est�n en la bloque 2.
import matlab.io.*

fptr=fits.openFile(file);

fits.movAbsHDU(fptr,2);

ydata=fits.readCol(fptr,1,index,1)';

fits.closeFile(fptr);
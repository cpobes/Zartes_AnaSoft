function FileList=GetFilesFromRp(IVset,Tbath,Rp)
%%%Funcion para dar la lista de ficheros a una Tbath dada a los porcentajes
%%%Rp. V0: hay que estar en el directorio raiz del TES a analizar.
%%%Pasar Tbath como string numerico en milikelvin sin el mK: Tbath='50'.

str=dir('*mK');
for i=1:length(str)
    if strfind(str(i).name,Tbath) & str(i).isdir, break;end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
end

Tdir=str(i).name
files=ls(strcat(str(i).name,'\HP_Noise*'));
[ii,jj]=size(files)
for i=1:ii
Iaux(i)=sscanf(char(regexp(files(i,:),'\d+(\.\d*)?','match')),'%f');
end
Iaux;
Ibs=BuildIbiasFromRp(IVset,Rp);

for i=1:length(Rp)
    [~,jj]=min(abs(Iaux-Ibs(i)))
    FileList{i}=files(jj,:);
end


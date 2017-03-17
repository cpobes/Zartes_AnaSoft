function IVset=corregir1rama(data)
%%%corregir datos de una rama de bajada positiva.
%%%ojo a si hay 2 o 4 columnas.
IVset.ibias=data(:,2)*1e-6;
if data(1,2)==0
    IVset.vout=data(:,4)-data(1,4);
else
    IVset.vout=data(:,4)-data(end,4);
end
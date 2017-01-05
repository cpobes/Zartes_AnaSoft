function IVset=corregir1rama(data)
%%%corregir datos de una rama de bajada positiva.
IVset.ibias=data(:,2)*1e-6;
IVset.vout=data(:,4);%%-data(end,4);
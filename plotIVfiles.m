function zs=plotIVfiles(Rf)
%plot IVs at different Tbath from files.
Rsh=2e-3;
Rpar=0.12e-3;

[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2015\Dec2015\Z(w)\*','','Multiselect','on');

T=strcat(path,file);

if (iscell(T))
for i=1:length(T),
    data{i}=importdata(T{i});
    ibs{i}=data{i}(:,1);%%%
    vouts{i}=data{i}(:,2);%%%
    plotIVs(vouts{i},ibs{i},Rf),hold on,
end
else
    data=importdata(T);
    
    ibs=data(:,1);%%%
    vouts=data(:,2);%%%
    plotIVs(vouts,ibs,Rf)
end
grid on
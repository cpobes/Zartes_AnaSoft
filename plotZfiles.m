function zs=plotZfiles(TFS,L,ind)
%plot Ztes at different OP from files a partir de TFS y L.
Rsh=2e-3;
Rpar=0.12e-3;

[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2015\Dec2015\Z(w)\*','','Multiselect','on');

T=strcat(path,file);
%ind=1:801;%
if (iscell(T))
for i=1:length(T),
    data{i}=importdata(T{i});
    tf{i}=data{i}(:,2)+1i*data{i}(:,3);%%%!!!ojo al menos.
    Rth=Rsh+Rpar+2*pi*L*data{i}(:,1)*1i;
    %tf{i}=conj(tf{i});
    %size(TFS),size(tf{i}),size(Rth)
    ztes{i}=(TFS./tf{i}-1).*Rth;
    plot(ztes{i}(ind),'.'),hold on,
end
else
    data=importdata(T);
    tf=data(:,2)+1i*data(:,3);%%%!!!ojo al menos.
    Rth=Rsh+Rpar+2*pi*L*data(:,1);%*1i;
    %tf{i}=conj(tf{i});
    %size(TFS),size(tf{i}),size(Rth)
    ztes=(TFS./tf-1).*Rth;
    plot(ztes(ind),'.'),hold on,
end
grid on
zs=ztes;
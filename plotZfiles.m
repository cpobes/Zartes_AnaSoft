function zs=plotZfiles(TFS,L,ind)
%plot Ztes at different OP from files a partir de TFS y L.
Rsh=2e-3;
Rpar=0.12e-3;

[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\Dec2015\Z(w)\*','','Multiselect','on');

T=strcat(path,file);

for i=1:length(T),
    data{i}=importdata(T{i});
    size(data{i});
    tf{i}=data{i}(:,2)+1i*data{i}(:,3);
    Rth=Rsh+Rpar+2*pi*L*data{i}(:,1);
    ztes{i}=(TFS./tf{i}-1).*Rth;
    plot(ztes{i}(ind),'.'),hold on,
end
grid on
zs=ztes;
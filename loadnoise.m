function [data,file]=loadnoise();
%carga de golpe ficheros tomados en el HP3265a
%se accede a los datos como data{i}(:,:)
[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\*','','Multiselect','on');

T=strcat(path,file);

for i=1:length(T),
    data{i}=importdata(T{i});
end
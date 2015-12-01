function data=loadppms();
%carga de golpe ficheros tomados en el PPMS con Header (32 lineas)
%se salta la primera columna, por lo que T=col3, R1=col6, R2=col8.
%se accede a los datos como data{i}(:,:)
[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\*.dat','','Multiselect','on')

T=strcat(path,file);
if(iscell(T))
for i=1:length(T),
    data{i}=csvread(T{i},32,1);
    saux=strcat('t',num2str(i),'=data{',num2str(i),'}(:,3);'),evalin('caller',saux);
    saux=strcat('r',num2str(i),'1','=data{',num2str(i),'}(:,6);'),evalin('caller',saux);
    saux=strcat('r',num2str(i),'2','=data{',num2str(i),'}(:,8);'),evalin('caller',saux);
end
else
    data=csvread(T,32,1);
    
    %error.pq?
    %saux=strcat('t','=data(:,3);');evalin('caller',saux);
    %saux=strcat('r1','=data(:,6);')%,evalin('caller',saux)
    %saux=strcat('r2','=data(:,8);'),evalin('caller',saux)
end

function [data,file]=loadnoise(varargin);
%carga de golpe ficheros tomados en el HP3265a
%se accede a los datos como data{i}(:,:)
[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\*','','Multiselect','on');

if nargin==0,
    skip=0;
else
    skip=varargin{1};
end

T=strcat(path,file);

for i=1:length(T),
    if iscell(T)
        data{i}=importdata(T{i},'\t',skip);%
        if(skip) data{i}=data{i}.data;end
    else
        data=importdata(T,'\t',skip);%
        if(skip) data=data.data;end
    end
end
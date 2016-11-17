function [data,file]=loadnoise(varargin);
%carga de golpe ficheros tomados en el HP3265a
%se accede a los datos como data{i}(:,:)

if nargin==0,
    skip=0;
else
    skip=varargin{1};
end

if nargin>1
    path=varargin{2};
    file=varargin{3};
    %iscell(file)
else
    [file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\*','','Multiselect','on');
    %iscell(file)
end

if ~iscell(file)
    [i,j]=size(file);
    for ii=1:i
        xfile(ii)={deblank(file(ii,:))};
    end
    file=xfile;
end

T=strcat(path,file);

for i=1:length(T),
    if iscell(T)
        data{i}=importdata(T{i});% ,'\t',skip
        if(skip) data{i}=data{i}.data;end
    else
        data=importdata(T);% ,'\t',skip
        if(skip) data=data.data;end
    end
end
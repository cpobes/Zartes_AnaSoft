function TF=importTF()

[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\Mayo2016\Z(w)\*','','Multiselect','off');

T=strcat(path,file);

    data=importdata(T);
    tf=data(:,2)+1i*data(:,3);
    re=data(:,2);
    im=data(:,3);
    f=data(:,1);
    TF.tf=tf;
    TF.re=re;
    TF.im=im;
    TF.f=f;
function plotZ_Tb_Rp(anaStruct,Rp,Temp)
%%%% funcion para pintar la Z(w) y los fits a un porcentaje a partir de una
%%%% estructura.

olddir=pwd;

datadir=anaStruct.analizeOptions.datadir;
cd(datadir);
 
[mIV,mP]=GetTbathIndex(Temp,anaStruct);

fileList=GetFilesFromRp(anaStruct.IVset(mIV),Temp,Rp,'\TF_*')

%%%%
str=dir('*mK')
Tbathstr=num2str(Temp);
for i=1:length(str)
    str(i)
    if strfind(str(i).name,Tbathstr) & str(i).isdir, break;end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
end
%%%%%
strcat(str(i).name,'\',fileList)

tfList=importTF(strcat(str(i).name,'\',fileList));

for i=1:length(tfList)
      zList{i}=GetZfromTF(tfList{i},anaStruct.TFS,anaStruct.circuit);
      figure(10)
      plot(zList{i}.tf,'.-','color',[ 0    0.4470    0.7410]),hold on
      figure(11)
      semilogx(zList{i}.f,imag(zList{i}.tf),'.-'),hold on
      semilogx(zList{i}.f,real(zList{i}.tf),'.-'),hold on
end

if length(anaStruct.P(mP).p(1).parray)==3
    px=[GetPparam(anaStruct.P(mP).p,'Zinf')' GetPparam(anaStruct.P(mP).p,'Z0')' GetPparam(anaStruct.P(mP).p,'taueff')' ];
else
    px=[GetPparam(anaStruct.P(mP).p,'Zinf')' GetPparam(anaStruct.P(mP).p,'Z0')' ...
    GetPparam(anaStruct.P(mP).p,'taueff')' GetPparam(anaStruct.P(mP).p,'geff')' GetPparam(anaStruct.P(mP).p,'t_1')' ];
end


for i=1:length(Rp)
    [~,jj]=min(abs([anaStruct.P(mP).p.rp]-Rp(i)));
    zx=fitZ(px(jj,:),anaStruct.TFS.f);
    figure(10)
    plot(zx(:,1),zx(:,2),'-r');
    figure(11)
    semilogx(anaStruct.TFS.f,zx(:,2),'-r');
    semilogx(anaStruct.TFS.f,zx(:,1),'-k');
end

cd(olddir)


function plotZ_Tb_Rp(anaStruct,Rp,Temp)
%%%% funcion para pintar la Z(w) y los fits a un porcentaje a partir de una
%%%% estructura. ej: Rp=[0.2:0.05:0.8]. Temp=50 (temperatura en mK).

olddir=pwd;

%%%Cargamos la estructura colores para los plots.
colordir=GetCloudDataDir();
cd(colordir);
load('colores.mat')%%%esto carga la estructura colores.
cd(olddir)

datadir=anaStruct.analizeOptions.datadir;
cd(datadir);
 
[mIV,mP]=GetTbathIndex(Temp,anaStruct);%%%Se asume que para todas las temperaturas se toman tanto datos positivos como negativos.

polarity=1;%%%1:P,0:N.
if polarity
    fileList=GetFilesFromRp(anaStruct.IVset(mIV),Temp,Rp,'\TF_*')
    color=colores.azul;
else
    cd('Negative Bias')
    fileList=GetFilesFromRp(anaStruct.IVsetN(mIV),Temp,Rp,'\TF_*')
    color=colores.naranja;
end

Tdir=GetDirfromTbath(Temp);
strcat(Tdir,'\',fileList)

tfList=importTF(strcat(Tdir,'\',fileList));

figZs=findobj('name','Zfig');
figImRe=findobj('name','ImRefig');
if ~isempty(figZs) hZ=figZs.Number; else figZs=figure('name','Zfig');hZ=figZs.Number; end
if ~isempty(figImRe) hImRe=figImRe.Number; else figImRe=figure('name','ImRefig');hImRe=figImRe.Number; end

for i=1:length(tfList)
      zList{i}=GetZfromTF(tfList{i},anaStruct.TFS,anaStruct.circuit);
      figure(hZ)
      plot(zList{i}.tf,'.-','color',color),hold on
      %plot(zList{i}.tf(625),'o','linewidth',5);%%% pintamos el punto en que f=2e3.(indice 529).<-serie 2Z4? f=8e3 (625)1Z2.
      figure(hImRe)
      semilogx(zList{i}.f,imag(zList{i}.tf),'.-'),hold on
      %semilogx(zList{i}.f,real(zList{i}.tf),'.-'),hold on
end

% if length(anaStruct.P(mP).p(1).parray)==3
%     px=[GetPparam(anaStruct.P(mP).p,'Zinf')' GetPparam(anaStruct.P(mP).p,'Z0')' GetPparam(anaStruct.P(mP).p,'taueff')' ];
% else
%     px=[GetPparam(anaStruct.P(mP).p,'Zinf')' GetPparam(anaStruct.P(mP).p,'Z0')' ...
%     GetPparam(anaStruct.P(mP).p,'taueff')' GetPparam(anaStruct.P(mP).p,'geff')' GetPparam(anaStruct.P(mP).p,'t_1')' ];
% end

if polarity
    for ii=1:length([anaStruct.P(mP).p.rp]) px(ii,:)=anaStruct.P(mP).p(ii).parray; end
else
    for ii=1:length([anaStruct.PN(mP).p.rp]) px(ii,:)=anaStruct.PN(mP).p(ii).parray; end
end

m_name=anaStruct.analizeOptions.ZfitOpt.ThermalModel;
model=BuildThermalModel(m_name);
func=model.function

%%%Pintamos el modelo
for i=1:length(Rp)
    if polarity
        [~,jj]=min(abs([anaStruct.P(mP).p.rp]-Rp(i)));
    else
        [~,jj]=min(abs([anaStruct.PN(mP).p.rp]-Rp(i)));
    end
    
    %zx=fitZ(px(jj,:),anaStruct.TFS.f);
    zx=func(px(jj,:),anaStruct.TFS.f);
    figure(hZ)
    plot(zx(:,1),zx(:,2),'-k');grid on
    figure(hImRe)
    semilogx(anaStruct.TFS.f,zx(:,2),'-r');
    %semilogx(anaStruct.TFS.f,zx(:,1),'-k');
    grid on
end

cd(olddir)


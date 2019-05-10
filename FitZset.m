function P=FitZset(IVset,circuit,TES,TFS,varargin)
%%%Ajuste automático de Z(w) para varias temperaturas de baño

%%%definimos variables necesarias.
Rsh=circuit.Rsh;
Rpar=circuit.Rpar;
L=circuit.L;
fS=TFS.f;
Rn=circuit.Rn;
Rn=TES.Rn;

%%%si no pasamos files busca todos los directorios del tipo xxxmK
if nargin==4
%     f=ls;
%     [i,j]=size(f);
%     fc=mat2cell(f,ones(1,i),j)
%     fc=deblank(fc)
%     %dirs=regexp(fc,'^\d+mK','match');
%     dirs=regexp(fc,'^\d+.?\d*mK$','match');
%     dirs=dirs(~cellfun('isempty',dirs))
%     for i=1:length(dirs) dirs{i}=char(dirs{i}),end
%     for i=1:length(dirs),aux(i)=sscanf(dirs{i},'%f');end
%     aux=sort(aux);
%     for i=1:length(aux) dirs{i}=strcat(num2str(aux(i)),'mK'),end
    f=dir;
    f=f([f.isdir]);
    dirs={};
    for i=1:length(f)
            dirs{end+1}=regexp(f(i).name,'^\d+.?\d*mK$','match');
    end
    dirs=dirs(~cellfun('isempty',dirs))
    for i=1:length(dirs) dirs{i}=char(dirs{i}), end
    for i=1:length(dirs),aux(i)=sscanf(dirs{i},'%f');end
    [ii,jj]=sort(aux)
    %for i=1:length(aux) dirs{i}=strcat(num2str(aux(i)),'mK'),end
    dirs=dirs(jj)

    %return;
elseif nargin>4
    t=varargin{1};
    for iii=1:length(t)
        str=dir('*mK');
        for jjj=1:length(str)
            if strfind(str(jjj).name,num2str(t(iii))) & str(jjj).isdir, break;end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
        end
        dirs{iii}=str(jjj).name;
    end
end

if nargin==6
    TFN=varargin{2};
    tfsn=TFS.tf./TFN.tf;
end
dirs
pause(1)

for i=1:length(dirs)
    %%%buscamos los ficheros a analizar en cada directorio.
    d=pwd;
    %dirs{i},pause(1)
%    files=ls(strcat(d,'\',dirs{i}));
    
%%%devolvemos los ficheros en orden de fecha. Pero ojo si se pierde esa
%%%info. Creo ListInBiasOrder para que se listen siempre en orden de
%%%corriente.
    %D=dir(strcat(d,'\',dirs{i},'\TF*'));
    D=strcat(d,'\',dirs{i},'\TF*')
    %D=strcat(d,'\',dirs{i},'\PXI_TF*')
%     [~,s2]=sort([D(:).datenum]',1,'descend');
%     filesZ={D(s2).name}%%%ficheros en orden de %Rn!!!
    filesZ=ListInBiasOrder(D);
    
    %D=dir(strcat(d,'\',dirs{i},'\HP*'));
    NoiseBaseName='\HP_noise*';
    %NoiseBaseName='\PXI_noise*';%%%'\PXI*';%%%'\HP*'
    D=strcat(d,'\',dirs{i},NoiseBaseName);
%     [~,s2]=sort([D(:).datenum]',1,'descend');
%     filesNoise={D(s2).name}%%%ficheros en orden de %Rn!!!
    filesNoise=dir(D);
    if ~isempty(filesNoise) filesNoise=ListInBiasOrder(D);end
    
%     [ii,jj]=size(files);
%     filesc=mat2cell(files,ones(1,ii),jj);
%     filesZ=regexp(filesc,'^TF_-?\d+.?\d+uA','match');
%     filesZ=filesZ(~cellfun('isempty',filesZ))
%     filesNoise=regexp(filesc,'^HP_noise_-?\d+.?\d+uA','match');
%     filesNoise=filesNoise(~cellfun('isempty',filesNoise));
%     %length(filesNoise)
%     for ii=1:length(filesZ) 
%         filesZ{ii}=char(filesZ{ii});
%         if ~isempty(filesNoise)filesNoise{ii}=char(filesNoise{ii});end
%     end
%     %filesc
    
    %%%buscamos la IV correspondiente a la Tmc dada
    Tbath=sscanf(dirs{i},'%dmK')
    pause(1)
    %Tind=[IVset.Tbath]*1e3==Tbath;
    [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IV=IVset(Tind);
    
    %%%hacemos loop en cada fichero a analizar.
    k=1;
    for jj=1:length(filesZ)
        %if mod(jj,4) continue;end %%%Para mostrar sólo una parte de los OPs.
        
        %thefile=strcat(d,'\',dirs{i},'\',filesZ{jj}); %%%quito '.txt' respecto a version anterior. 
        thefile=strcat(dirs{i},'\',filesZ{jj})
        if ~isempty(filesNoise) thenoisefile=strcat(d,'\',dirs{i},'\',filesNoise{jj}); end%%%quito'.txt'
        offset=0.11e-6;%-9e-6;
        Ib=sscanf(char(regexp(thefile,'-?\d+.?\d+uA','match')),'%fuA')*1e-6+offset
        %pause(1)%%debug
        
        %%%importamos la TF
            data=importdata(thefile);%size(data)
            tf=data(:,2)+1i*data(:,3);
            Rth=Rsh+Rpar+2*pi*L*data(:,1)*1i;
            ztes=(TFS.tf./tf-1).*Rth;
            ztes=ztes(~isinf(ztes));%%%%En datos mar19 RUN013 a 80mK e Ib=30uA hay puntos con tf=0 que da error.
            if nargin==6
                ztes=(TFS.tf./tf-1).*Rn./(tfsn-1);
            end
            
%             Cp=100e-12;
%             Zth=Rsh./(1+2*pi*Cp*data(:,1)*1i*Rsh)+Rpar+2*pi*L*data(:,1)*1i;
%             ztes=(TFS.tf./tf-1).*Zth;
            
            %plot(ztes,'.'),hold on
            %size(ztes)
        %%%valores iniciales del fit
            Zinf=real(ztes(end));
            Z0=real(ztes(1));
            Y0=real(1./ztes(1));
            %tau0=1e-4;
            indY=find(imag(ztes)==min(imag(ztes)));
            tau0=1/(2*pi*fS(indY(1)));%%%tau0 es el valor inicial de taueff. Lo estimamos a partir de la w_min
            tau1=1e-5;
            tau2=1e-5;
            d1=0.8;
            d2=0.1;
            feff0=1e2;
            
            %%%%condicion
            %ind_z=find(imag(ztes)<-1.5e-3);
            %ind_z=find(fS<0.5e4);%%%%filtro en frecuencias
            ind_z=1:length(ztes);
            
         %%%Hacemos el ajuste a Z(w)
            p0=[Zinf Z0 tau0];%%%1TB
            Lt=1e-9;
            %p0=[Zinf Z0 tau0 Lt];%%%1TB+reactancia.
            p04=0.01;%1/(0.7-IV.rtes(jj));
            %p0=[Zinf Z0 tau0 p04 1e-6];%%%p0 for 2 block model.
            %p0=[Zinf Z0 tau0 tau1 tau2 d1 d2];%%%p0 for 3 block model.
            %pinv0=[Zinf 1/Y0 tau0];
            %%%%%%%%%%%%%%%%%%%Thermal model definition.
            model=BuildThermalModel();
            p0=model.X0;
            p0=[Zinf Z0 tau0];%%%
            LB=model.LB;%%%[-Inf -Inf 0 0 0]
            UB=model.UB;%%%[]
            %UB=[0.035 0 1];
            XDATA=fS(ind_z);
            YDATA=[real(ztes(ind_z)) imag(ztes(ind_z))];
            %YDATA=imag(ztes(ind_z));
            fitfunc=model.function;%%%@fitZ
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitfunc,p0,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
            ci = nlparci(p,aux2,'jacobian',auxJ);
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,pinv0,fS,[real(1./zt{i}) imag(1./zt{i})]);%%%uncomment for inverse Ztes fit.
            %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(ztes)],[0 -Inf 0],[1 Inf 1]);%%%uncomment for real part only.
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,zt{i});%%%uncommetn for complex parameters
                %p=[p(1) 1/p(2) 1/p(3)];%solo para 1/Ztesvfits.                
         
                %p=Analize_STB_Z(fS,ztes)%%%Otra forma de estimar los parámetros
         %%%Extraemos los parámetros del ajuste.
         
            param=GetModelParameters(p,IV,Ib,TES,circuit);
            resN=aux1;
            P(i).p(jj)=param;
            P(i).residuo(jj).resN=resN;
            P(i).residuo(jj).ci=ci;
            
            %%%%%%%%%%%%%%%%%%%%%%Pintamos Gráficas
                boolShow=1;
            if boolShow
                %if param.rp> 0.5 continue;end %%%%ojo!!!
                ind=1:3:length(ztes);
                %figure('name',strcat('Z',num2str(i)));
                
                %if p(2)<0 && p(2)>-30*1e-3
                    plot(1e3*ztes(ind),'.','color',[0 0.447 0.741],'markerfacecolor',[0 0.447 0.741],'markersize',15),grid on,hold on;%%% Paso marker de 'o' a '.'
                    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold');
                    xlabel('Re(mZ)','fontsize',12,'fontweight','bold');
                    ylabel('Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
                    ImZmin(jj)=min(imag(1e3*ztes));
                    ylim([min(-15,min(ImZmin)-1) 1])
                    fZ=fitZ(p,fS);plot(1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2);hold on
                    if k==1 || jj==length(filesZ)
                        aux_str=strcat(num2str(round(param.rp*100)),'% R_n');
                        %%%annotation('textarrow',1e3*p(2)*[1 1],[5 0],aux_str,'fontweight','bold');
                        %text(p(2)*1e3,3,aux_str,'fontweight','bold');
                    end
                    k=k+1;
                    %print(findobj('name',strcat('Z',num2str(i))),strcat('Z',num2str(i)),'-dpng','-r300')
                    %close(findobj('name',strcat('Z',num2str(i))))
                %end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
         %%%Analizamos el ruido
         if ~isempty(filesNoise)
            [noisedata,file]=loadnoise(0,dirs{i},filesNoise{jj});%%%quito '.txt'
            OP=setTESOPfromIb(Ib,IV,param);
            noiseIrwin=noisesim('irwin',TES,OP,circuit);
            %noiseIrwin.squid=3e-12;
            %size(noisedata),size(noiseIrwin.sum)
            f=logspace(0,6,1000);%%%Ojo, la definición de 'f' debe coincidir con la que hay dentro de noisesim!!!
            sIaux=ppval(spline(f,noiseIrwin.sI),noisedata{1}(:,1));
            NEP=sqrt(V2I(noisedata{1}(:,2),circuit).^2-noiseIrwin.squid.^2)./sIaux;
            %[~,nep_index]=find(~isnan(NEP))
            %pause(2)
            NEP=NEP(~isnan(NEP));%%%Los ruidos con la PXI tienen el ultimo bin en NAN.
            
            RES=2.35/sqrt(trapz(noisedata{1}(1:length(NEP),1),1./medfilt1(NEP,20).^2))/2/1.609e-19
            P(i).ExRes(jj)=RES;
            P(i).ThRes(jj)=noiseIrwin.Res;
            
            %%%Excess noise trials.
            %%%Johnson Excess
            if(0) %%% calculo de Mjo y Mph por separado.
            findx=find(noisedata{1}(:,1)>1e4 & noisedata{1}(:,1)<4.5e4);
            xdata=noisedata{1}(findx,1);
            %ydata=sqrt(V2I(noisedata{1}(findx,2),circuit.Rf).^2-noiseIrwin.squid.^2);
            ydata=medfilt1(NEP(findx)*1e18,20);
            %size(ydata)
            if sum(ydata==Inf) %%%1Z1_23A @70mK 1er punto da error.
                P(i).M(jj)=0;
            else
                P(i).M(jj)=lsqcurvefit(@(x,xdata) fitnoise(x,xdata,TES,OP,circuit),0,xdata,ydata);
            end
            %%%phonon Excess
            findx=find(noisedata{1}(:,1)>1e2&noisedata{1}(:,1)<1e3);
            ydata=median(NEP(findx)*1e18);
            if sum(ydata==inf)
                P(i).Mph(jj)=0;
            else
                ymod=median(ppval(spline(f,noiseIrwin.NEP*1e18),noisedata{1}(findx,1)));
                P(i).Mph(jj)=sqrt((ydata/ymod).^2-1);%%%%12feb19. antes estaba mal!
            end
            end
            
            %%%%%Calculo Mjo y Mph conjuntamente.
%             findx=find(noisedata{1}(:,1)>5e2 & noisedata{1}(:,1)<1e5);
%             xdata=noisedata{1}(findx,1);
%             ydata=medfilt1(NEP(findx)*1e18,40);
%             mxx=lsqcurvefit(@(x,xdata) fitnoise(x,xdata,TES,OP,circuit),[0 0],xdata,ydata);
%             P(i).M(jj)=mxx(1);
%             P(i).Mph(jj)=mxx(2);
            
            %%%debug. Recalculo ThRes incluyendo Mjo.
            %noiseIrwin=noisesim('irwin',TES,OP,circuit,P(i).M(jj));%%%recalculo el ThRes.
            %P(i).ThRes(jj)=noiseIrwin.Res;%%%Resolucion teorica con el Mjo incluido.
            
%             %%%funciona igual fitnoise y fitjohnson.
%             %parameters.TES=TES;parameters.OP=OP;parameters.circuit=circuit;         
%             %P(i).M(jj)=lsqcurvefit(@(x,xdata) fitjohnson(x,xdata,parameters),[0 0],xdata,ydata);
if(1)
            findx=find(noisedata{1}(:,1)>2e2 & noisedata{1}(:,1)<10e4);
            xdata=noisedata{1}(findx,1);
            ydata=medfilt1(NEP(findx)*1e18,40);
            parameters.TES=TES;parameters.OP=OP;parameters.circuit=circuit;        
            if sum(isinf(ydata))==0  %%%Algunos OP dan NEP Inf.pq?
                maux=lsqcurvefit(@(x,xdata) fitjohnson(x,xdata,parameters),[0 0],xdata,ydata);
                P(i).M(jj)=maux(2);
                P(i).Mph(jj)=maux(1);
            else
                P(i).M(jj)=0;
                P(i).Mph(jj)=0;
            end
end

%             %%%Recalculo ExRes* incluyendo los M en el modelo para ver el impacto del fallo en la primera década del analizador!!
%             auxnoise=noisesim('irwin',TES,OP,circuit,P(i).M(jj));%P(i).M(jj)
%             nepaux=sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;
%             findx=find(auxnoise.f>1e2);
%             P(i).ExRes(jj)=2.35/sqrt(trapz(auxnoise.f(findx),1./nepaux(findx).^2))/2/1.609e-19;
            
% %         ns=ppval(spline(f,noiseIrwin.sum),noisedata{1}(:,1));
% %         excess(:,1)=noisedata{1}(:,1);
% %         excess(:,2)=V2I(noisedata{1}(:,2),circuit.Rf)-noiseIrwin.squid-ns;
% %         excess;
% %         P(i).exnoise{jj}=excess;
         end         
    end
        %%%Pasamos ExRes y ThRes dentro de P.p
        if ~isempty(filesNoise)
        for jj=1:length(P(i).ExRes) %%%(filesZ) 
            P(i).p(jj).ExRes=P(i).ExRes(jj);
            P(i).p(jj).ThRes=P(i).ThRes(jj);
            P(i).p(jj).M=real(P(i).M(jj));
            P(i).p(jj).Mph=real(P(i).Mph(jj));
        end
        end
        P(i).Tbath=Tbath*1e-3;%%%se lee en mK
end
if ~isempty(filesNoise) P=rmfield(P,{'ExRes','ThRes','M','Mph'});end
    

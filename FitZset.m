function P=FitZset(IVset,circuit,TES,TFS,varargin)
%%%Ajuste automático de Z(w) para varias temperaturas de baño.
%%%% V2.(11-Junio-2019). Incluyo condicion para poder pasar como 5º argumento una
%%%% estructura seleccionando si se analizan datos de HP o PXI. El uso es
%%%% backwards compatible, el quinto parámetro puede seguir siendo un
%%%% vector de temperaturas.

%%%definimos variables necesarias.
Rsh=circuit.Rsh;
Rpar=circuit.Rpar;
L=circuit.L;
fS=TFS.f;
Rn=circuit.Rn;
Rn=TES.Rn;

% 
% nargin
% isstruct(varargin{1})
% nargin==5 && isstruct(varargin{1})
% nargin==4 || (nargin==5 && isstruct(varargin{1}))

%%%si no pasamos files busca todos los directorios del tipo xxxmK
%%%Ahora podemos pasar como 5º argumento una estructura con los datos que
%%%% se quieren analizar (HP o PXI) y también si se quieren todas las temps
%%%% por defecto o solo algunas.
if nargin==4 || (nargin==5 && isstruct(varargin{1}))
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
    if(nargin==5)
            options=varargin{1};
    elseif nargin==4
            options.TFdata='HP';
            options.Noisedata='HP';
            options.ThermalModel='default';
            options.NoiseFilterModel.model='default';
            options.NoiseFilterModel.wmed=40;
    end
    
    options
    
    if isfield(options,'Temps') & ~isempty(options.Temps)
        %%%       
            t=options.Temps;
            for iii=1:length(t)
                str=dir('*mK');
                for jjj=1:length(str)
                    if strfind(str(jjj).name,num2str(t(iii))) & str(jjj).isdir, break;end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
                end
                dirs{iii}=str(jjj).name;
            end
        %%%
    else
        f=dir;
        f=f([f.isdir]);
        dirs={};
        for i=1:length(f)
            dirs{end+1}=regexp(f(i).name,'^\d+.?\d*mK$','match');
        end
        %dirs=dirs(~cellfun('isempty',dirs))%%%NO HACE lo que deberia.
        newdirs={};
        for i=1:length(dirs) 
            dirs{i}=char(dirs{i}); 
            if length(ls(char(dirs{i})))>2 newdirs{end+1}=dirs{i};end
        end
        for i=1:length(newdirs),aux(i)=sscanf(newdirs{i},'%f');end
        [ii,jj]=sort(aux)
        %for i=1:length(aux) dirs{i}=strcat(num2str(aux(i)),'mK'),end
        dirs=newdirs(jj)
    end

    %return;
elseif nargin>4 && isnumeric(varargin{1})
            options.TFdata='HP';
            options.Noisedata='HP';
            options.ThermalModel='2TB_intermediate';%'default';
            options.NoiseFilterModel.model='default';
            options.NoiseFilterModel.wmed=40;
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
    files=ls(strcat(d,'\',dirs{i}));
%     if length(files)==2 %%%%Ya había condicion para evitar dirs vacios
%     pero no estaba funcionando bien.
%         P(i)=nan;
%         continue;
%     end %%%aunque esté vacío lista . y ..
    
%%%devolvemos los ficheros en orden de fecha. Pero ojo si se pierde esa
%%%info. Creo ListInBiasOrder para que se listen siempre en orden de
%%%corriente.

    if strcmp(options.TFdata,'HP')        
        %D=dir(strcat(d,'\',dirs{i},'\TF*'));
        D=strcat(d,'\',dirs{i},'\TF*')
    elseif strcmp(options.TFdata,'PXI')
        D=strcat(d,'\',dirs{i},'\PXI_TF*')
    end
%     [~,s2]=sort([D(:).datenum]',1,'descend');
%     filesZ={D(s2).name}%%%ficheros en orden de %Rn!!!
    filesZ=ListInBiasOrder(D);
    
    if strcmp(options.Noisedata,'HP')   
        %D=dir(strcat(d,'\',dirs{i},'\HP*'));
        NoiseBaseName='\HP_noise*';
    elseif strcmp(options.Noisedata,'PXI')   
        NoiseBaseName='\PXI_noise*';%%%'\PXI*';%%%'\HP*'
    end
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
    Tbath=sscanf(dirs{i},'%dmK');
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
        %pause(1)
        if ~isempty(filesNoise) thenoisefile=strcat(d,'\',dirs{i},'\',filesNoise{jj}); end%%%quito'.txt'
        
        if isfield(circuit,'ioff')
            offset=circuit.ioff;
        else
            offset=0;
        end
        %offset=0.11e-6;%-9e-6;!!!!!
        
        Ib=sscanf(char(regexp(thefile,'-?\d+.?\d+uA','match')),'%fuA')*1e-6+offset
        if isempty(Ib) Ib=0;end
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
            
            %%%%condicion en frecuencias
            %ind_z=find(imag(ztes)<-1.5e-3);
            %ind_z=find(fS>500 & fS<100e3);%%%%filtro en frecuencias
            %ind_z=30:length(ztes)-500;%
            ind_z=1:length(ztes);
            %fS
            if isfield(options,'f_ind')
                ind_z=[];
                for iii=1:length(options.f_ind(:,1))
                    %find(fS>options.f_ind(i,1) & fS<options.f_ind(i,2))'
                    %ind_z
                    ind_z=[ind_z; find(fS>options.f_ind(iii,1) & fS<options.f_ind(iii,2))];
                end
            end
        %%%valores iniciales del fit
            Zinf=real(ztes(ind_z(end)));
            Z0=real(ztes(ind_z(1)));
            Y0=real(1./ztes(1));
            %tau0=1e-4;
            indY=find(imag(ztes)==min(imag(ztes)));
            tau0=1/(2*pi*fS(indY(1)));%%%tau0 es el valor inicial de taueff. Lo estimamos a partir de la w_min
            tau1=1e-5;
            tau2=1e-5;
            d1=0.8;
            d2=0.1;
            feff0=1e2;
            
            
         %%%Hacemos el ajuste a Z(w)
            p0=[Zinf Z0 tau0];%%%1TB
            %Lt=1e-9;
            %p0=[Zinf Z0 tau0 Lt];%%%1TB+reactancia.
            p04=0.01;%1/(0.7-IV.rtes(jj));
            %p0=[Zinf Z0 tau0 p04 1e-6];%%%p0 for 2 block model.
            %p0=[Zinf Z0 tau0 tau1 tau2 d1 d2];%%%p0 for 3 block model.
            %pinv0=[Zinf 1/Y0 tau0];
            %%%%%%%%%%%%%%%%%%%Thermal model definition.
            
            model=BuildThermalModel(options.ThermalModel);           
            p0=model.X0;
            rps=[0:0.01:1];
            Ibs=BuildIbiasFromRp(IV,rps);
            [~,iii]=min(abs(Ibs-Ib*1e6));
            switch model.nombre
                case 'default'
                    p0=[Zinf Z0 tau0];%%%
                case '2TB_hanging'
                    %p0=[Zinf Z0 tau0 100 1/(2*pi*1e3)];
                    %p0=[Zinf Z0 1/(2*pi*1e2) 1 1/(2*pi*3e3)];
                    %p0=[0.008 -0.01 1.4e-3 50 2.5e-3];

                    if rps(iii)<0.51%0.38
                        %p0=[0.0075 -0.0883 2e-4 7.7778 2e-3];
                        %p0=[Zinf Z0 2e-4 7.7778 2e-3];
                        p0=[Zinf Z0 9.3770e-06 1 1.5e-3];
                    elseif rps(iii)>=0.51 && rps(iii)<0.6
                        p0=[0.0085 -0.01 -2e-4 -7.45 0.0022];%%%p0(40%)
                    elseif rps(iii)==0.7
                        p0=[0.0120 -0.1365  -0.3597 -1.35 0.0030];%%%p0(75%)
                    elseif rps(iii)>0.7
                        %p0=[0.0120 0.0365 -3.3686e-05 -0.86 0.0030];%%%p0(75%)
                        p0=[0.0706   -0.3593    -5.8333e-04   -2.1667     2.6923e-04];%%%p0(75%)
                    end
                case '2TB_intermediate'
                    p0=[Zinf Z0 tau0 1 1/(2*pi*2e3)];
                    if rps(iii)>0.7%0.8
                        %p0=[0.0706   -0.3593    -5.8333e-04   -2.1667     2.6923e-04];
                        p0=[Zinf   Z0   sign(Zinf)*1/(2*pi*1e3)    sign(Zinf)*10     1/(2*pi*2e3)];
                    end
                case '2TB_hanging_Lh-a'
                    rps=[0:0.01:1];
                    Ibs=BuildIbiasFromRp(IV,rps);
                    [~,iii]=min(abs(Ibs-Ib*1e6));
                    if rps(iii)<0.4
                        p0=[0.0075 1.009 2e-4 0.07 2e-3];
                    elseif rps(iii)>=0.4 && rps(iii)<=0.7
                        p0=[0.0085 0.9329 -2e-4 0.5 0.0022];%%%p0(40%)
                    elseif rps(iii)>0.7
                        p0=[0.0120 0.2214 -3.3686e-05 0.6697 0.0030];%%%p0(75%)
                    end
            end
            
            LB=model.LB;%%%[-Inf -Inf 0 0 0]
            UB=model.UB;%%%[]
            %UB=[0.035 0 1];
            XDATA=fS(ind_z);
            switch model.nombre
                case {'default' '2TB_hanging' '2TB_hanging_Lh-a' '2TB_intermediate' '2TB_parallel'}
                    YDATA=[real(ztes(ind_z)) imag(ztes(ind_z))];
                case 'ImZ'
                    YDATA=imag(ztes(ind_z));
            end
            fitfunc=model.function;%%%@fitZ
            if p0(3)==Inf, p0(3)=1e-3;end
            p0
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
            [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitfunc,p0,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
            ci = nlparci(p,aux2,'jacobian',auxJ);
            catch
                error('error in lsqcurvefit');
                dirs{i}
                continue;
            end
            
            %%%%%%Weighted Fitting Method.            
            %weight=sqrt((XDATA));
            %weight=1;
            %costfunction=@(p)weight.*sqrt(sum((fitfunc(p,XDATA)-YDATA).^2,2));
            %[p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p0,LB,UB);%%%uncomment for real parameters.
            %ci = nlparci(p,aux2,'jacobian',auxJ);
            
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,pinv0,fS,[real(1./zt{i}) imag(1./zt{i})]);%%%uncomment for inverse Ztes fit.
            %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(ztes)],[0 -Inf 0],[1 Inf 1]);%%%uncomment for real part only.
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,zt{i});%%%uncommetn for complex parameters
                %p=[p(1) 1/p(2) 1/p(3)];%solo para 1/Ztesvfits.                
         
                %p=Analize_STB_Z(fS,ztes)%%%Otra forma de estimar los parámetros
         %%%Extraemos los parámetros del ajuste.
         
            if isfield(options,'fixCopt')
                opt.boolC=options.fixCopt;
            else
                opt.boolC=0;
            end
              opt.C=TES.CN;                
              opt.model=model.nombre;
              %Ib
              %pause(1)%
             param=GetModelParameters(p,IV,Ib,TES,circuit,opt);
            resN=aux1;
            %P(i).p(jj)=param;
            if jj==1 
                P(i).p(jj)=param;%%%Necesario inicializar los campos?
            else
                P(i).p(jj)=UpdateStruct(P(i).p(jj-1),param);
            end
            P(i).p(jj).p0=p0;
            P(i).residuo(jj).resN=resN;
            P(i).residuo(jj).ci=ci;
            
            %%%%%%%%%%%%%%%%%%%%%%Pintamos Gráficas
                boolShow=0;
            if boolShow
                %if param.rp> 0.5 continue;end %%%%ojo!!!
                ind=1:3:length(ztes);
                %figure('name',strcat('Z',num2str(i)));
                
                %if p(2)<0 && p(2)>-30*1e-3
                    figure(2)%,hold off
                    plot(1e3*ztes(ind_z),'.','color',[0 0.447 0.741],'markerfacecolor',[0 0.447 0.741],'markersize',15),grid on,hold on;%%% Paso marker de 'o' a '.'
                    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold');
                    xlabel('Re(mZ)','fontsize',12,'fontweight','bold');
                    ylabel('Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
                    ImZmin(jj)=min(imag(1e3*ztes(ind_z)));
                    ylim([min(-15,min(ImZmin)-1) 1])
                    fZ=fitZ(p,fS);plot(1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2);hold on
                    if k==1 || jj==length(filesZ)
                        aux_str=strcat(num2str(round(param.rp*100)),'% R_n');
                        %%%annotation('textarrow',1e3*p(2)*[1 1],[5 0],aux_str,'fontweight','bold');
                        %text(p(2)*1e3,3,aux_str,'fontweight','bold');
                    end
                    figure(3)%,hold off
                    semilogx(fS(ind_z),imag(1e3*ztes(ind_z)),'.','color',[0 0.447 0.741]);hold on
                    semilogx(fS,1e3*fZ(:,2),'r','linewidth',2);
                    k=k+1;
                    %print(findobj('name',strcat('Z',num2str(i))),strcat('Z',num2str(i)),'-dpng','-r300')
                    %close(findobj('name',strcat('Z',num2str(i))))
                %end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
         %%%Analizamos el ruido
         %medfilt_w=40;
         if ~isempty(filesNoise)
             dirs{i}, filesNoise{jj}
            [noisedata,file]=loadnoise(0,dirs{i},filesNoise{jj});%%%quito '.txt'
            %param
            OP=setTESOPfromIb(Ib,IV,param);
            OP.parray=p;%%%añadido para modelos a 2TB.
            %noiseIrwin=noisesim('irwin',TES,OP,circuit);
            parameters.TES=TES;parameters.OP=OP;parameters.circuit=circuit;%%%movido de L391.
            model=BuildThermalModel(options.ThermalModel,parameters);%%%lo estamos llamando 2 veces pq en la primera, OP no está definido.
            noiseIrwin=model.noise;%%%%El modelo de ruido se define en BuilThermalModel
            %noiseIrwin.squid=3e-12;
            %size(noisedata),size(noiseIrwin.sum)
            f=logspace(0,6,1000);%%%Ojo, la definición de 'f' debe coincidir con la que hay dentro de noisesim!!!
            %noiseIrwin
            try
            sIaux=ppval(spline(f,noiseIrwin.sI),noisedata{1}(:,1));
            NEP=sqrt(V2I(noisedata{1}(:,2),circuit).^2-noiseIrwin.squid.^2)./sIaux;
            %[~,nep_index]=find(~isnan(NEP))
            %pause(2)
            NEP=NEP(~isnan(NEP));%%%Los ruidos con la PXI tienen el ultimo bin en NAN.
            noise_filt_model=options.NoiseFilterModel
            filtNEP=filterNoise(NEP,noise_filt_model);
            RES=2.35/sqrt(trapz(noisedata{1}(1:length(NEP),1),1./filtNEP.^2))/2/1.609e-19;
            P(i).ExRes(jj)=RES;
            P(i).ThRes(jj)=noiseIrwin.Res;
            catch %me da error el 1Z10_62B RUN007,50mK,92uA.
                P(i).ExRes(jj)=0;
                P(i).ThRes(jj)=0;
                NEP=ones(1,length(noisedata{1}(:,1)))*Inf;
            end
            
            %%%Excess noise trials.
            %%%Johnson Excess
%             if(0) %%% calculo de Mjo y Mph por separado.
%                 findx=find(noisedata{1}(:,1)>1e4 & noisedata{1}(:,1)<4.5e4);
%                 xdata=noisedata{1}(findx,1);
%                 %ydata=sqrt(V2I(noisedata{1}(findx,2),circuit.Rf).^2-noiseIrwin.squid.^2);
%                 ydata=medfilt1(NEP(findx)*1e18,20);
%                 %size(ydata)
%                 if sum(ydata==Inf) %%%1Z1_23A @70mK 1er punto da error.
%                     P(i).M(jj)=0;
%                 else
%                     P(i).M(jj)=lsqcurvefit(@(x,xdata) fitnoise(x,xdata,TES,OP,circuit),0,xdata,ydata);
%                 end
%                 %%%phonon Excess
%                 findx=find(noisedata{1}(:,1)>1e2&noisedata{1}(:,1)<1e3);
%                 ydata=median(NEP(findx)*1e18);
%                 if sum(ydata==inf)
%                     P(i).Mph(jj)=0;
%                 else
%                     ymod=median(ppval(spline(f,noiseIrwin.NEP*1e18),noisedata{1}(findx,1)));
%                     P(i).Mph(jj)=sqrt((ydata/ymod).^2-1);%%%%12feb19. antes estaba mal!
%                 end
%             end%%% end_if
            
            %%%%%Calculo Mjo y Mph conjuntamente.Version1.
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
            mphfrange=[2e2,1e3];
            mjofrange=[5e3,1e5];
            faux=noisedata{1}(:,1);
            findx=find((faux>mphfrange(1) & faux<mphfrange(2)) | (faux>mjofrange(1) & faux<mjofrange(2)));
            xdata=noisedata{1}(findx,1);
            %ydata=medfilt1(NEP(findx)*1e18,medfilt_w);
            %ydata=colfilt(NEP(findx)*1e18,[15 1],'sliding',@min);
            %ydata=medfilt1(ydata,medfilt_w);
            
            %parameters.TES=TES;parameters.OP=OP;parameters.circuit=circuit;        
            if sum(isinf(NEP))==0
            %if sum(isinf(ydata))==0  %%%Algunos OP dan NEP Inf.pq?
                ydata=filterNoise(NEP(findx)*1e18,noise_filt_model);
                maux=lsqcurvefit(@(x,xdata) fitjohnson(x,xdata,parameters),[0 0],xdata,ydata);
                %maux=lsqcurvefit(@(x,xdata) fitnoise(x,xdata,TES,OP,circuit),[0 0],xdata,ydata);
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
end%%% forr principal
%if ~isempty(filesNoise) P=rmfield(P,{'ExRes','ThRes','M','Mph'});end
try P=rmfield(P,{'ExRes','ThRes','M','Mph'});catch end;
    

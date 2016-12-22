function P=FitZset(IVset,circuit,TES,TFS,varargin)
%%%Ajuste automático de Z(w) para varias temperaturas de baño

%%%definimos variables necesarias.
Rsh=circuit.Rsh;
Rpar=circuit.Rpar;
L=circuit.L;
fS=TFS.f;

%%%si no pasamos files busca todos los directorios del tipo xxxmK
if nargin==4
    f=ls;
    [i,j]=size(f);
    fc=mat2cell(f,ones(1,i),j);
    dirs=regexp(fc,'^\d+mK','match');
    dirs=dirs(~cellfun('isempty',dirs));
    for i=1:length(dirs) dirs{i}=char(dirs{i});end
elseif nargin==5
    t=varargin{1};
    for i=1:length(t) dirs{i}=strcat(num2str(t(i)),'mK');end
end

dirs
pause(1)
for i=1:length(dirs)
    %%%buscamos los ficheros a analizar en cada directorio.
    d=pwd;
    dirs{i},pause(1)
    files=ls(strcat(d,'\',dirs{i}));
    [ii,jj]=size(files);
    filesc=mat2cell(files,ones(1,ii),jj);
    filesZ=regexp(filesc,'^TF_-?\d+.?\d+uA','match');
    filesZ=filesZ(~cellfun('isempty',filesZ))
    filesNoise=regexp(filesc,'^HP_noise_-?\d+.?\d+uA','match');
    filesNoise=filesNoise(~cellfun('isempty',filesNoise));
    %length(filesNoise)
    for ii=1:length(filesZ) 
        filesZ{ii}=char(filesZ{ii});
        if ~isempty(filesNoise)filesNoise{ii}=char(filesNoise{ii});end
    end
    %filesc
    
    %%%buscamos la IV correspondiente a la Tmc dada
    Tbath=sscanf(dirs{i},'%dmK');
    %Tind=[IVset.Tbath]*1e3==Tbath;
    [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IV=IVset(Tind);
    
    %%%hacemos loop en cada fichero a analizar.

    for jj=1:length(filesZ)
        thefile=strcat(d,'\',dirs{i},'\',filesZ{jj},'.txt');
        if ~isempty(filesNoise) thenoisefile=strcat(d,'\',dirs{i},'\',filesNoise{jj},'.txt');end
        Ib=sscanf(char(regexp(thefile,'-?\d+.?\d+uA','match')),'%fuA')*1e-6
        
        %%%importamos la TF
            data=importdata(thefile);%size(data)
            tf=data(:,2)+1i*data(:,3);
            Rth=Rsh+Rpar+2*pi*L*data(:,1)*1i;
            ztes=(TFS.tf./tf-1).*Rth;
            %plot(ztes,'.'),hold on
            %size(ztes)
        %%%valores iniciales del fit
            Zinf=real(ztes(end));
            Z0=real(ztes(1));
            Y0=real(1./ztes(1));
            tau0=1e-4;
            feff0=1e2;
            
         %%%Hacemos el ajuste a Z(w)
            p0=[Zinf Z0 tau0];
            pinv0=[Zinf 1/Y0 tau0];
             %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,[real(ztes) imag(ztes)]);%%%uncomment for real parameters.
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,pinv0,fS,[real(1./zt{i}) imag(1./zt{i})]);%%%uncomment for inverse Ztes fit.
            [p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(ztes)],[0 -Inf 0],[1 Inf 1]);%%%uncomment for real part only.
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,zt{i});%%%uncommetn for complex parameters
                %p=[p(1) 1/p(2) 1/p(3)];%solo para 1/Ztesvfits.                
         
         %%%Extraemos los parámetros del ajuste.
            param=GetModelParameters(p,IV,Ib,TES,circuit);
            resN=aux1;
            P(i).p(jj)=param;
            P(i).residuo(jj)=resN;
            
         %%%Analizamos el ruido
         if ~isempty(filesNoise)
            [noisedata,file]=loadnoise(0,dirs{i},strcat(filesNoise{jj},'.txt'));
            OP=setTESOPfromIb(Ib,IV,param);
            noiseIrwin=noisesim('irwin',TES,OP,circuit);
            noiseIrwin.squid=3e-12;
            %size(noisedata),size(noiseIrwin.sum)
            f=logspace(0,6);
            sIaux=ppval(spline(f,noiseIrwin.sI),noisedata{1}(:,1));
            NEP=(V2I(noisedata{1}(:,2),circuit.Rf)-noiseIrwin.squid)./sIaux;
            RES=2.35/sqrt(trapz(noisedata{1}(:,1),1./NEP.^2))/2/1.609e-19;
            P(i).ExRes(jj)=RES;
            P(i).ThRes(jj)=noiseIrwin.Res;
         end
            
    end
    
    %%%Ordenamos los parametros de menor a mayor por si el ls los da
    %%%desordenados. Brute force.mejorar.
    [Y,kk]=sort([P(i).p(:).rp]);
    for jj=1:length(Y), P(i).p(jj).rp=Y(jj);end

%     for jj=1:length(Y),P(i).p(jj).bi=[P(i).p(kk(jj)).bi];end
%     for jj=1:length(Y),P(i).p(jj).L0=[P(i).p(kk(jj)).L0];end
%     for jj=1:length(Y),P(i).p(jj).tau0=[P(i).p(kk(jj)).tau0];end
%     for jj=1:length(Y),P(i).p(jj).C=[P(i).p(kk(jj)).C];end
%     for jj=1:length(Y),P(i).p(jj).ai=[P(i).p(kk(jj)).ai];end
%     for jj=1:length(Y),P(i).p(jj).Zinf=[P(i).p(kk(jj)).Zinf];end
%     for jj=1:length(Y),P(i).p(jj).Z0=[P(i).p(kk(jj)).Z0];end
%     for jj=1:length(Y),P(i).p(jj).taueff=[P(i).p(kk(jj)).taueff];end
%     for jj=1:length(Y),P(i).residuo(jj)=[P(i).residuo(kk(jj))];end
    
    aux=[P(i).p(kk).bi];for jj=1:length(Y),P(i).p(jj).bi=aux(jj);end
    aux=[P(i).p(kk).L0];for jj=1:length(Y),P(i).p(jj).L0=aux(jj);end
    aux=[P(i).p(kk).tau0];for jj=1:length(Y),P(i).p(jj).tau0=aux(jj);end
    aux=[P(i).p(kk).C];for jj=1:length(Y),P(i).p(jj).C=aux(jj);end
    aux=[P(i).p(kk).ai];for jj=1:length(Y),P(i).p(jj).ai=aux(jj);end
    aux=[P(i).p(kk).Zinf];for jj=1:length(Y),P(i).p(jj).Zinf=aux(jj);end
    aux=[P(i).p(kk).Z0];for jj=1:length(Y),P(i).p(jj).Z0=aux(jj);end
    aux=[P(i).p(kk).taueff];for jj=1:length(Y),P(i).p(jj).taueff=aux(jj);end
    aux=[P(i).residuo];for jj=1:length(Y),P(i).residuo=aux(jj);end
        
    P(i).Tbath=Tbath;
end
    

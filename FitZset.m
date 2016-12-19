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
    dirs=regexp(fc,'\d+mK','match');
    dirs=dirs(~cellfun('isempty',dirs));
    for i=1:length(dirs) dirs{i}=char(dirs{i});end
elseif nargin==5
    t=varargin{1};
    for i=1:length(t) dirs{i}=strcat(num2str(t(i)),'mK');end
end
%dirs
for i=1:length(dirs)
    %%%buscamos los ficheros a analizar en cada directorio.
    d=pwd;
    files=ls(strcat(d,'\',dirs{i}));
    [ii,jj]=size(files);
    filesc=mat2cell(files,ones(1,ii),jj);
    filesc=regexp(filesc,'TF_\d+uA','match');
    filesc=filesc(~cellfun('isempty',filesc));
    for ii=1:length(filesc) filesc{ii}=char(filesc{ii});end
    %filesc
    
    %%%buscamos la IV correspondiente a la Tmc dada
    Tbath=sscanf(dirs{i},'%dmK');
    Tind=find([IVset.Tbath]*1e3==Tbath);
    IV=IVset(Tind);
    
    %%%hacemos loop en cada fichero a analizar.
    for jj=1:length(filesc)
        thefile=strcat(d,'\',dirs{i},'\',filesc{jj},'.txt')
        Ib=sscanf(char(regexp(thefile,'\d+uA','match')),'%duA')*1e-6;
        %Tbath
        %pause(1)
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
            
         %%%Hacemos el ajustes
            p0=[Zinf Z0 tau0];
            pinv0=[Zinf 1/Y0 tau0];
             %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,[real(ztes) imag(ztes)]);%%%uncomment for real parameters.
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,pinv0,fS,[real(1./zt{i}) imag(1./zt{i})]);%%%uncomment for inverse Ztes fit.
            [p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(ztes)],[0 -Inf 0],[1 Inf 1]);%%%uncomment for real part only.
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,zt{i});%%%uncommetn for complex parameters
    
                %p=[p(1) 1/p(2) 1/p(3)];%solo para 1/Ztesvfits.
            param=GetModelParameters(p,IV,Ib,TES,circuit);
            resN=aux1;
            P(i).p(jj)=param;
            P(i).res(jj)=resN;
    end
    
    %%%Ordenamos los parametros de menor a mayor por si el ls los da
    %%%desordenados. Brute force.mejorar.
    [Y,kk]=sort([P(i).p(:).rp]);
    for jj=1:length(Y), P(i).p(jj).rp=Y(jj);end
    aux=[P(i).p(kk).bi];for jj=1:length(Y),P(i).p(jj).bi=aux(jj);end
    aux=[P(i).p(kk).L0];for jj=1:length(Y),P(i).p(jj).L0=aux(jj);end
    aux=[P(i).p(kk).tau0];for jj=1:length(Y),P(i).p(jj).tau0=aux(jj);end
    aux=[P(i).p(kk).C];for jj=1:length(Y),P(i).p(jj).C=aux(jj);end
    aux=[P(i).p(kk).ai];for jj=1:length(Y),P(i).p(jj).ai=aux(jj);end
    aux=[P(i).p(kk).Zinf];for jj=1:length(Y),P(i).p(jj).Zinf=aux(jj);end
    aux=[P(i).p(kk).Z0];for jj=1:length(Y),P(i).p(jj).Z0=aux(jj);end
    aux=[P(i).p(kk).taueff];for jj=1:length(Y),P(i).p(jj).taueff=aux(jj);end
    aux=[P(i).res];for jj=1:length(Y),P(i).res=aux(jj);end
        
    P(i).Tbath=Tbath;
end
    

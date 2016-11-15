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
        thefile=strcat(d,'\',dirs{i},'\',filesc{jj},'.txt');
        
        Ib=sscanf(char(regexp(thefile,'\d+uA','match')),'%duA')*1e-6;
        
        %%%importamos la TF
            data=importdata(thefile);
            tf=data(:,2)+1i*data(:,3);
            Rth=Rsh+Rpar+2*pi*L*data(:,1);
            ztes=(TFS.tf./tf-1).*Rth;
            
        %%%valores iniciales del fit
            Zinf=real(ztes(end));
            Z0=real(ztes(1));
            Y0=real(1./ztes(1));
            tau0=1e-4;
            feff0=1e2;
            
         %%%Hacemos el ajustes
            p0=[Zinf Z0 tau0];
            pinv0=[Zinf 1/Y0 tau0];
                [p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,fS,[real(ztes) imag(ztes)]);%%%uncomment for real parameters.
                %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,pinv0,fS,[real(1./zt{i}) imag(1./zt{i})]);%%%uncomment for inverse Ztes fit.
            %[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitReZ,p0,fS,[real(ztes)]);%%%uncomment for real part only.
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
    for jj=1:length(Y),P(i).p(jj).bi=[P(i).p(kk(jj)).bi];end
    for jj=1:length(Y),P(i).p(jj).L0=[P(i).p(kk(jj)).L0];end
    for jj=1:length(Y),P(i).p(jj).tau0=[P(i).p(kk(jj)).tau0];end
    for jj=1:length(Y),P(i).p(jj).C=[P(i).p(kk(jj)).C];end
    for jj=1:length(Y),P(i).p(jj).ai=[P(i).p(kk(jj)).ai];end
    for jj=1:length(Y),P(i).p(jj).Zinf=[P(i).p(kk(jj)).Zinf];end
    for jj=1:length(Y),P(i).p(jj).Z0=[P(i).p(kk(jj)).Z0];end
    for jj=1:length(Y),P(i).p(jj).taueff=[P(i).p(kk(jj)).taueff];end
    for jj=1:length(Y),P(i).res(jj)=[P(i).res(kk(jj))];end
        
    P(i).Tbath=Tbath;
end
    

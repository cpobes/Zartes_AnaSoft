function PulseParameters=AnalizaPulseFITS(file,varargin)
%%%%Funciona analoga a AnalizaPulseDir pero para fichero fits
import matlab.io.*
%%%%%%%%%%%%%%%%%%%%%%%%%
DataUnit=2;
A=0;B=0;

for i=1:nargin-1
    if isnumeric(varargin{i})
        DataUnit=varargin{i};
    end
    if isstruct(varargin{i})
        OP=varargin{i};%%%Pasamos el OP. Aunque mejor guardarlo en el FITS.
        Rsh=OP.circuit.Rsh+OP.circuit.Rpar;%%%!!!Ojo a no nombrarla igual que el record length RL!
        if isfield(OP,'I0')
            I0=OP.I0;
        end
        if isfield(OP,'oft')
            oft=OP.oft;%%%%%%estandarizar esto.
        else
            oft=[];
        end

        %Ibias=OP.Ibias;
        %A=(I0-Ibias)*Rsh;
        %B=Rsh;
        %%%%%%%%OPTIONS%%%%%%%%%%
%         t0ini=0.1;%%%Esto se tiene que leer del fichero tambien.
%         optfraction=0.055;%Dic21:0.128; Ene24:0.055.
%         topt=t0ini+optfraction;
        if isfield(OP,'tini')
            t0ini=OP.tini;
        else
            t0ini=0.1;
        end
        if isfield(OP,'ToptFraction')
            optfraction=OP.ToptFraction;
        else
            optfraction=0.055;%Dic21:0.128; Ene24:0.055.
        end
        if isfield(OP,'boolfit')%ajustamos?
            boolfit=OP.boolfit;
        else
            boolfit=0;
        end
        if isfield(OP,'wfilt')%filtrado?
            wfilt=OP.wfilt;
        else
            wfilt=1;
        end
    end
end

%%%
infor=fitsinfo(file);
Npulsos=infor.BinaryTable(DataUnit-1).Rows
L=infor.BinaryTable(DataUnit-1).FieldSize(1);
%Npulsos=10000;

%%%
topt=t0ini+optfraction;
%trunc_area_range=(1080:1440)';
if isfield(OP,'fit_range')
    fit_range=OP.fit_range;
else
    fit_range=t0ini*L/2:L/2;%9000:1e5;%Dic21:1000:10000;
end

if isfield(OP,'index')
    index=OP.index;
    if isempty(index) index=1:Npulsos;end
else
    index=1:Npulsos;
end
        
fptr=fits.openFile(file);
%fits.movAbsHDU(fptr,3)%%%el fichero de la LNCS est� en dos tablas.
try
fits.movAbsHDU(fptr,DataUnit);
%Npulsos=fits.getNumRows(fptr)

SR=str2num(fits.readKey(fptr,'SR'));
RL=str2num(fits.readKey(fptr,'RL'));
Ibias=str2num(fits.readKey(fptr,'Ibias'));
try
    I0=str2num(fits.readKey(fptr,'I0'));
    A=(I0-Ibias)*Rsh;%Asegurarse de que I0 e Ibias est�n en Amp!
    B=Rsh;
catch
end
time=(1:RL)/SR;
DT=1/SR;

%fhandle=@(p,t)p(1)*heaviside(t-p(4)).*(exp(-(t-p(4))/p(2))-exp(-(t-p(4))/p(3))+exp(-(t-p(4))/p(5)))/(p(2)+p(5)-p(3));
%p0=[0.7635    1.0460    0.0085    2.0009    6.4844]*1e-3;
%p0=[0.3979    0.8078    0.0048    2.0032    3.7450]*1e-3;
%p0=[5.6925e-04 4.7974*1e-3 4.5895*1e-6 2.0026*1e-3 0.9105*1e-3]; %%%Pulso promedio de los 6.4KeV del p40mK_142uA_PI08 de Julio2020.
%p0=[4.2514e-04 4.0084*1e-3 7.0401*1e-6 2e-3 0.8903*1e-3]; %%%Pulso promedio de 6.4KeV a 90mK Julio2020.

%px=fhandle(p0,time);
%ofilt=px/sum(px);

%fh2=@(p,t)p(2)*ofilt+p(1);
%fnorm=@(p,t) heaviside(t-p(4)).*(exp(-(t-p(4))/p(2))-exp(-(t-p(4))/p(3))+exp(-(t-p(4))/p(5)))/(p(2)+p(5)-p(3));
%fh3=@(p,t)p(2)*fhandle([1 p0(2) p0(3) p(3) p0(5)],time)+p(1);
%fhandle=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4))+p(5);%%%simple
%fhandle=BuildPulseHandle(1);%

if isfield(OP,'MeanPulse')
    Mpulse=OP.MeanPulse;
    fhandle=@(p,x)p*interp1(Mpulse(:,1),Mpulse(:,2),x)
    p0=0.200;
else
    %fhandle=BuildPulseHandle('2e');%
end
minprominence=0.05;%0.005(dic21),0.05(Jan24,Rf=3e3).
polarity=1;% 1: positivos, 0:negativos.

for i=1:Npulsos%
    if ~ismember(i,index)
        continue;
    end
    %raw=fitsread(file,'binarytable',1,'TableColumns',1,'TableRows',1);%%5Lentisimo.
    try
        raw=fits.readCol(fptr,1,i,1);
    catch
        continue;
    end
    %L=length(raw);Lo podemos calcular fuera.
    pulso(:,1)=(1:L)/SR;%%%
    
    pulso(:,2)=(-1)^(polarity+1)*raw;%%%Pulsos negativos! o Positivos!!!
        
    dc(i)=mean(pulso(1:L*t0ini/2,2));
    dc_std(i)=std(pulso(1:L*t0ini/2,2));
    area(i)=sum(medfilt1(pulso(int16(L*t0ini-10):end,2),wfilt)-dc(i));
    optArea(i)=sum(medfilt1(pulso(int16(L*t0ini-10):L*topt,2),wfilt)-dc(i));
    [maux,miaux]=max(medfilt1(pulso(:,2),wfilt));
    amp(i)=maux-dc(i);
    tmax(i)=time(miaux);
    Amax(i)=maux;%
    
    %%%Self Calibrated Energy.E_ETF ec.58 Irwin.
    ipulse=V2I(pulso(:,2),OP.circuit);
    idc=V2I(dc(i),OP.circuit);
    suma_i=sum(medfilt1(ipulse,wfilt)-idc)*DT;
    suma_i2=sum((medfilt1(ipulse,wfilt)-idc).^2)*DT;
    Eetf(i)=A*suma_i+B*suma_i2;
    
    %%%%%FILTRO OPTIMO%%%%%%%%
    if ~isempty(oft)
        %OFT_Energy(i)=sum(pulso(:,2).*oft(:));
        %OFT_Energy(i)=OFTEcalcWjit(pulso,[pulso(:,1) oft(:)]);
        %%%temporal baseline filtering.
        if isfield(OP,'filtopt')
            filtopt=OP.filtopt;
        else
            filtopt.boolfit=0;
        end
        if amp(i)<0.01 && filtopt.boolfit
            pulso(:,2)=filtfilt(filtopt.filter,pulso(:,2));
        end
        if isfield(OP,'oftrange')
            oftrange=OP.oftrange;
        else
            oftrange=1:L;
        end
        OFT_Energy(i)=OFTEcalcWjit(pulso(oftrange,:),oft(oftrange,:));%metemos time en oft tb.
    end
    %energy(i)=sum((pulso(:,2)-dc(i))'.*ofilt);%%%estimacion OF.
    %energy0(i)=sum(pulso(:,2)'.*ofilt);
    %ind=find(pulso(:,2)-dc(i)<AMPthr);%%%seleccionamos un rango que no est� saturado para hacer el ajuste.
    %ind=find(pulso(:,1)<0.12 & pulso(:,1)>0.1);
    
    [v,t]=findpeaks(pulso(:,2),pulso(:,1),'minpeakprominence',minprominence);
    %v=0;t=0;
    npeaks(i)=numel(v);
    ntimes(i).times=t;
    
    timestamp(i)=fits.readCol(fptr,2,i,1);
    tbath(i)=fits.readCol(fptr,3,i,1);
    rsensor(i)=fits.readCol(fptr,4,i,1);
    
        if(boolfit && npeaks(i)==1)
        ind_fit=fit_range;
        %p0=[0.01 0.001 1e-5];
        %fhandle=@(p,x)p(1)*(exp(-(x-t0)/p(2))-exp(-(x-t0)/p(3))).*heaviside(x-t0);%%%ojo a t0.
        %p0=[0.1 0.001 1e-5 0.002];�
        %p0=[0.1 1e3 10 2000];
        %p0=[0.7635    1.0460    0.0085    2.0009    6.4844]*1e-3;

        %fhandle=@(p,t)p(1)*heaviside(t-p(4)).*(exp(-(t-p(4))/p(2))-exp(-(t-p(4))/p(3))+exp(-(t-p(4))/p(5)))/(p(2)+p(5)-p(3));
        %fhandle=@(p,x)p(1)*(1+p(5)*exp(-(x-p(4))/p(2))-(1+p(5))*exp(-(x-p(4))/p(3))).*heaviside(x-p(4));%%%step
        %p0=[0 404 2e-3];
        %p0=[0.57 566 2e-3]; %%%p0 para fh3 del pulsopromedio del p40mK_142uA_PI08.
        %fit_pulso=lsqcurvefit(fhandle,p0,pulso(ind_fit,1),pulso(ind_fit,2)-dc(i));
        %size(fh2(p0,ind_fit))
        %size(pulso(ind_fit,2))
        %ft_p3=lsqcurvefit(fh3,p0,ind_fit,pulso(ind_fit,2)');
        
        %p0=[0.1 1e-3 10e-6 1.2e-3 dc(i)];%%%tau1-tau2 para pulso positivo.
        %p0=[-0.1102 4.586e-06 0.0008222 0.005003 dc(i)
        %0.003218];Jan24.Rf3e3,SR:1e6
        %p0=[-0.3086    1.8e-05    9.2927e-04    0.0040   dc(i)    0.0026];
        ft_p=lsqcurvefit(fhandle,p0,pulso(fit_range,1),pulso(fit_range,2));
        
        if length(p0)>1
            dcfit(i)=ft_p(5);
            Afit(i)=ft_p(1);
            t0fit(i)=ft_p(4);
        else
            dcfit(i)=mean(fhandle(p0,1:L*t0ini/2));%ft_p(5);
            Afit(i)=ft_p(1);
            t0fit(i)=0;%ft_p(4);
        end
        area_fit(i)=sum(fhandle(ft_p,pulso(fit_range,1))-dcfit(i));
        fit_param(i,:)=ft_p;
%         area_corrected(i)=sum(fhandle(fit_pulso,pulso(ind_fit,1)));
%         tau_rise(i)=fit_pulso(3);
%         tau_fall(i)=fit_pulso(2);
%         A(i)=fit_pulso(1);
%         t0(i)=fit_pulso(4);
        elseif boolfit && npeaks(i)~=0
            dcfit(i)=0;
            Afit(i)=0;
            t0fit(i)=0;
            area_fit(i)=0;
            fit_param(i)=0;
    end
    if ~mod(i,10) ['pulso ' num2str(i)],end
end
fits.closeFile(fptr);
    PulseParameters.area=area;
    %PulseParameters.trunc_area=trunc_area;
    PulseParameters.optArea=optArea;
    PulseParameters.dc=dc;
    PulseParameters.dc_std=dc_std;
    PulseParameters.amp=amp;
    PulseParameters.tmax=tmax;
    PulseParameters.Amax=Amax;
    PulseParameters.npeaks=npeaks;
    PulseParameters.ntimes=ntimes;
    PulseParameters.Eetf=Eetf;
    %PulseParameters.energy=energy;
    %PulseParameters.e0=energy0;
    PulseParameters.timestamp=timestamp;
    PulseParameters.tbath=tbath;
    PulseParameters.rsensor=rsensor;
    PulseParameters.minprominence=minprominence;
    if ~isempty(oft)
        PulseParameters.OFT_Energy=OFT_Energy;
    end
    if(boolfit)
%     PulseParameters.fit.area_corrected=area_corrected;
%     PulseParameters.fit.tau_rise=tau_rise;
%     PulseParameters.fit.tau_fall=tau_fall;
%     PulseParameters.fit.t0=t0;
%     PulseParameters.fit.A=A;
        PulseParameters.fit.dc=dcfit;
        PulseParameters.fit.Afit=Afit;
        PulseParameters.fit.t0fit=t0fit;
        PulseParameters.fit.area_fit=area_fit;
        PulseParameters.fit.parameters=fit_param;
    end
catch
    fits.closeFile(fptr);
end
function zs=plotZfiles(TFS,circuit,varargin)
%plot Ztes at different OP from files a partir de TFS y L.
Rsh=circuit.Rsh;
Rpar=circuit.Rpar;
L=circuit.L;
%Rsh=2e-3;
%Rpar=0.12e-3;

[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\May2016\Mayo2016_pcZ(w)\Z(w)\*','','Multiselect','on');
%file
T=strcat(path,file);
%ind=1:801;%
if nargin>2,
    ind=varargin{1};
    if nargin>3,
    for i=1:length(varargin)-1
        h(i)=varargin{i+1};
    end
    end
else
    ind=1:length(TFS.f);
h(1)=figure;
h(2)=figure;
end

if (iscell(T))
for i=1:length(T),
    data{i}=importdata(T{i});
    tf{i}=data{i}(:,2)+1i*data{i}(:,3);%%%!!!ojo al menos.
    Rth=Rsh+Rpar+2*pi*L*data{i}(:,1)*1i;
    %tf{i}=conj(tf{i});
    %size(TFS),size(tf{i}),size(Rth)
    ztes{i}=1.0*((TFS./tf{i}-1).*Rth);
    figure(h(1)),plot(ztes{i}(ind),'.'),grid on,hold on,
    xlabel('Re(Z)');ylabel('Im(Z)'),title('Ztes with fits (red)');
    figure(h(2)),semilogx(data{i}(:,1),real(ztes{i}(ind)),'.',data{i}(:,1),imag(ztes{i}(ind)),'.r'),hold on
    xlabel('Freq(Hz)(Z)');title('Real (blue) and Imaginary (red) parts of Ztes with fits (black)');
end
else
    data=importdata(T);
    tf=data(:,2)+1i*data(:,3);%%%!!!ojo al menos.
    Rth=Rsh+Rpar+2*pi*L*data(:,1);%*1i;
    %tf{i}=conj(tf{i});
    %size(TFS),size(tf{i}),size(Rth)
    ztes=(TFS./tf-1).*Rth;
    figure(h(1)),plot(ztes(ind),'.'),hold on,
    figure(h(2)),semilogx(data(:,1),real(ztes(ind)),'.',data(:,1),imag(ztes(ind)),'.r'),hold on
end
grid on
zs=ztes;
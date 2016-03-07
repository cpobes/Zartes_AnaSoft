function zs=plotZfiles(TFS,L,ind,varargin)
%plot Ztes at different OP from files a partir de TFS y L.
Rsh=2e-3;
Rpar=0.12e-3;

[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\Feb2016\Z(w)\*','','Multiselect','on');

T=strcat(path,file);
%ind=1:801;%
if nargin>3,
    for i=1:length(varargin)
        h(i)=varargin{i};
    end
else
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
    ztes{i}=(TFS./tf{i}-1).*Rth;
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
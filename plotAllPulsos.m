function plotAllPulsos()
%%%funcion para pintar y superponer los pulsos de una carpeta

dir='';
basename='PXI_Pulso_*';
faux=ls(strcat(dir,basename));

hold off

for i=1:length(faux(:,1)) 
    pulso=importdata(faux(i,:));
    if isempty(pulso)
        {'pulso' i 'vacio'}
    else
        {'pulso' i }
        L=length(pulso(:,1));
    plot(pulso(:,1)*1e3,pulso(:,2)-mean(pulso(1:round(L/10),2)),'.-'),hold on,
    end
end

set(gca,'fontsize',20,'fontweight','bold')
xlabel('t(ms)')
ylabel('V_{out}')
axis tight
function OFTs=GetAutomaticOFTs(Pdata,files)
%%%funcion de analisis para sacar OFT automatico a partir del primer 
%%%analisis de datos
options=fitoptions('gauss3');
options.StartPoint=[100 0.004 1e-4 200 0.39 0.01 50 0.41 0.01];
options.Lower=zeros(1,9);
for i=1:length(Pdata)
    [h,x]=hist(Pdata(i).amp,1e4);
    [~,pos]=findpeaks(h,'MinPeakHeight',10,'MinPeakDistance',100);
    options.StartPoint=[100 x(pos(1)) 1e-4 200 x(pos(2)) 0.01 50 x(pos(3)) 0.01];
    fg{i}=fit(x(:),h(:),'gauss3',options);
    indNoise=find((Pdata(i).amp>fg{i}.b1-2.5*fg{i}.c1) & (Pdata(i).amp<fg{i}.b1+2.5*fg{i}.c1));
    MeanNoise=BuildMeanPSDfromFITS(files(i,:),indNoise);
    indKa=find((Pdata(i).amp>fg{i}.b2-2.5*fg{i}.c2) & (Pdata(i).amp<fg{i}.b2+2.5*fg{i}.c2));
    MeanPulse=BuildMeanPulsefromFITS(files(i,:),indKa);
    oft=BuildOptimalFilter(MeanPulse,MeanNoise);
    OFTs{i}=oft;
    i
end
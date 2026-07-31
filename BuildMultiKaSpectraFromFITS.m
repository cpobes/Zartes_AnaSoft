function Pdata=BuildMultiKaSpectraFromFITS(files,OP)
% necesitamos circuit y polarity. improve.
for i=1:length(files(:,1))
    file=files(i,:);
    %OP.circuit=circuit;
    RawData=AnalizaPulseFITS(file,OP);
    %RawData.circuit=circuit
   
    Pdata(i)=BuildMultiKaSpectraFromRawData(RawData);
end
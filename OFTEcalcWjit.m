function OFTE=OFTEcalcWjit(Mpulse,OFT)
%%%intento de calcular la E con el filtro optimo optimizando también el
%%%jitter
N=5;%pasos a dcha e izda.
oftj=OFT(:,2);
for i=[-N:N]
    if i<0
        oftj(1:end-abs(i))=OFT(1+abs(i):end,2);
    else
        oftj(1+i:end)=OFT(1:end-i,2);
    end
    oftEwjit(1+i+N)=sum(Mpulse(:,2).*oftj);
end
oftEwjit=spline([-N:N],oftEwjit,[-N:0.1:N]);
OFTE=max(oftEwjit);
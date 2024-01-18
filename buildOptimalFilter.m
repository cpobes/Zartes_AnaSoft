function OF=buildOptimalFilter(MeanPulse,MeanNoise)
%%%Construiccion del filtro optimo a partir del pulso y ruidos promedio.
%%%Suponemos MeanPulse=[time(:) V(:)]; y MeanNoise=[freqs(:) sqrt(PSD(:))];
oft=ifft(fft(Meanpulse(:,2))./abs(MeanNoise(:,2)).^2);
OF=double([MeanPulse(:,1) oft(:)]);

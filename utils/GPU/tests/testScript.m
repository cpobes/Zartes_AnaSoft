n = 1e7;  % Tama�o del problema

% Ejecuta las versiones y mide el tiempo
resultadoCPU = funcionCPU(n);
resultadoCPUVec = funcionCPUVectorizada(n);
resultadoGPU = funcionGPU(n);
resultadoGPUVec = funcionGPUVectorizada(n);
resultadoGPU2024 = funcionGPU2024(n);
%size(resultadoCPU)
%size(resultadoGPU)
%size(resultadoGPUVec)

% Verifica que los resultados sean similares
errorMaximo = max(abs(resultadoCPU - resultadoGPU));
fprintf('Error m�ximo entre CPU y GPU: %e\n', errorMaximo);

errorMaximoVec = max(abs(resultadoCPU(:) - resultadoGPUVec(:)));
fprintf('Error m�ximo entre CPU y GPU vectorizada: %e\n', errorMaximoVec);
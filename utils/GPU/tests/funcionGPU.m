% Funci�n paralelizada (GPU)
function resultado = funcionGPU(n)
    % Verifica que la GPU est� disponible
    if gpuDeviceCount == 0
        error('No se detect� ninguna GPU compatible con CUDA');
    end
    
    % Selecciona la GPU
    gpu = gpuDevice();
    
    % Inicializa el array en la GPU
    resultado_gpu = gpuArray(zeros(n, 1));
    
    tic;  % Inicia el cron�metro
    
    % Versi�n del bucle for para GPU
    for i = 1:n
        resultado_gpu(i) = sin(i) + cos(i^2);
    end
    
    % Transfiere los resultados de vuelta a la CPU
    resultado = gather(resultado_gpu);
    
    tiempo = toc;  % Detiene el cron�metro
    fprintf('Tiempo de ejecuci�n en GPU: %f segundos\n', tiempo);
    
    % Muestra informaci�n sobre la GPU
    fprintf('GPU utilizada: %s\n', gpu.Name);
    fprintf('Memoria GPU disponible: %f GB\n', gpu.AvailableMemory/1e9);
end
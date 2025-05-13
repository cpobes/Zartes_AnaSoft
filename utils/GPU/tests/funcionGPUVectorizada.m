% Funci�n GPU vectorizada
function resultado = funcionGPUVectorizada(n)
    % Verifica que la GPU est� disponible
    if gpuDeviceCount == 0
        error('No se detect� ninguna GPU compatible con CUDA');
    end
    
    % Selecciona la GPU
    gpu = gpuDevice();
    
    tic;  % Inicia el cron�metro
    
    % Crea un vector en la GPU
    x = gpuArray(1:n);
    
    % Vectoriza la operaci�n (sin bucle for)
    resultado_gpu = sin(x) + cos(x.^2);
    
    % Transfiere los resultados de vuelta a la CPU
    resultado = gather(resultado_gpu);
    
    tiempo = toc;  % Detiene el cron�metro
    fprintf('Tiempo de ejecuci�n en GPU vectorizada: %f segundos\n', tiempo);
end
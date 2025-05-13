% Funci�n CPU vectorizada
function resultado = funcionCPUVectorizada(n)
    tic;  % Inicia el cron�metro
    
    % Crea un vector en la CPU
    x = 1:n;
    
    % Vectoriza la operaci�n (sin bucle for)
    resultado = sin(x) + cos(x.^2);
    
    tiempo = toc;  % Detiene el cron�metro
    fprintf('Tiempo de ejecuci�n en CPU vectorizada: %f segundos\n', tiempo);
end
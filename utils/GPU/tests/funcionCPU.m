% Funci�n sin paralelizar (CPU)
function resultado = funcionCPU(n)
    resultado = zeros(n, 1);
    tic;  % Inicia el cron�metro
    for i = 1:n
        resultado(i) = sin(i) + cos(i^2);
    end
    tiempo = toc;  % Detiene el cron�metro
    fprintf('Tiempo de ejecuci�n en CPU: %f segundos\n', tiempo);
end
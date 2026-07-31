function [data_clean, TF] = removeOutliersMAD(data, nMAD)
    if nargin < 2
        nMAD = 3; % mismo default que rmoutliers
    end
    med = median(data);
    m = median(abs(data - med));
    % MATLAB usa un factor de escala 1.4826 para que MAD sea
    % comparable a la desviación estándar en datos normales
    madScaled = 1.4826 * m;
    TF = abs(data - med) > nMAD * madScaled;
    data_clean = data(~TF);
end
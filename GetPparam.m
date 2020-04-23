function par=GetPparam(p,name)
    %%%Funcion para devolver el array con los valores de un par�metro
    %%%determinado. Pasamos la estructura p a una temperatura fija, no la P()
    %%% V1: simplifico la llamada al par�metro y modifico para que devuelva
    %%% tambi�n el parray y p0.
    %par=eval(strcat('[','p.',name,']')); %%%old version.
    par=[p.(name)];
    n=length(p);
    np=length(par);
    par=reshape(par,[np/n, n]);

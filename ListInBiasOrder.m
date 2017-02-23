function files=ListInBiasOrder(D)
%%%Listar ficheros en orden de corriente de bias.

f=dir(D);
%length(f)
for i=1:length(f)
    str=regexp(f(i).name,'-?\d+.?\d+uA','match');
    Ibs(i)=sscanf(char(str),'%fuA');
end

[ii,jj]=sort(abs(Ibs),'descend');
f=f(jj);
files={f(:).name};
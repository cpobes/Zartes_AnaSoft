function files=ListInTbathOrder(pattern)
%%%funci�n para listar en orden de Tbath creciente.

files=ls(pattern);

for i=1:length(files(:,1)) ind(i)=sscanf(files(i,:),'%fmK*');end
[~,ii]=sort(ind);
files=files(ii,:);
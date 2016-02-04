function plotIVs(vout,ibias,Rf)

[ites,vtes,ptes,rtes]=GetIVTES(vout,ibias,Rf);

plot(vtes,ites,'.--'),grid on,hold on
xlabel('Vtes(V)');ylabel('Ites(A)');

% subplot(2,2,1);plot(ibias,vout,'.--'),grid on,hold on
% xlabel('Ibias(A)');ylabel('Vout(V)');
% subplot(2,2,3);plot(vtes,ites,'.--'),grid on,hold on
% xlabel('Vtes(V)');ylabel('Ites(A)');
% subplot(2,2,2);plot(vtes,ptes,'.--'),grid on,hold on
% xlabel('Vtes(V)');ylabel('Ptes(W)');
% subplot(2,2,4);plot(rtes,ptes,'.--'),grid on,hold on
% xlabel('Rtes(%)');ylabel('Ptes(W)');
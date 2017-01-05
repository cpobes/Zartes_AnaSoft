function plotNKGTset(rps,Gset)

subplot(2,2,1)
plot(rps,[Gset.n],'.-'),grid on,hold on
xlabel('Rtes(%Rn)');ylabel('n');

subplot(2,2,2)
plot(rps,[Gset.Tc],'.-'),grid on,hold on
xlabel('Rtes(%Rn)');ylabel('Tc(K)');

subplot(2,2,3)
plot(rps,[Gset.K],'.-'),grid on,hold on
xlabel('Rtes(%Rn)');ylabel('K(pW/K^n)');

subplot(2,2,4)
plot(rps,[Gset.G],'.-'),grid on,hold on
xlabel('Rtes(%Rn)');ylabel('G(pW/K)');
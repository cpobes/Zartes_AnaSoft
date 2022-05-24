function CheckTF(circuit)
tfn=TF_HP(circuit.Rn,circuit);
tfs=TF_HP(0,circuit);
plot(tfn.tf,'k','linewidth',2)
plot(tfs.tf,'m','linewidth',2)
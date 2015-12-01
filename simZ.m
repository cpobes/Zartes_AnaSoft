function tf=simZ(sys)
%simulates the measured complex impedance from the transfer fucntion of a
%system 'sys' which can be simulated with BuildLinearModel();
f=logspace(1,6);
for i=1:length(f)
    [u,t]=makeInputSin(f(i),20);y=lsim(sys,u,t);
    y=66.43*1e4/22*y;%from current to vout (only for y(:,1))
    ph(i)=phdiffmeasure(u(:,1),y(:,1));
    amp(i)=range(y(500:600,1))/range(u(:,1));%cogemos solo 1 o 2 ciclos
    %amp(i)=range(u(:,1))*400e-9/range(y(500:600,1));
end
tf=amp.*exp(1i*ph);%-(2.5e-3)-1i*2*pi*f*400e-9;
ztes=(66.43*1e4/22)*400e-9./tf-(2.5e-3)-1i*2*pi*f*400e-9;
        
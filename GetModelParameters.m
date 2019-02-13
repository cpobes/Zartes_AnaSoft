function param=GetModelParameters(p,IVmeasure,Ib,TES,Circuit)
%extrae los parámetros térmicos del sistema a partir de un modelo térmico y
%conociendo el punto de operación y la 'G'

%known parameters
%R0=210e-3;%79e-3;
%P0=80e-15;%77e-15;
%I0=(P0/R0)^.5;
%G=1.66e-12;%1.7e-12;
%T0=0.155;%;0.07;
%global R0 P0 I0 T0 G C ai bi

Rn=TES.Rn;
T0=TES.Tc;
G0=TES.G0;
[iaux,ii]=unique(IVmeasure.ibias,'stable');
vaux=IVmeasure.vout(ii);
[m,i3]=min(diff(vaux)./diff(iaux));
pp=spline(iaux(1:i3),vaux(1:i3));%%ojo, el spline no es bueno fuera de la transición.
Vout=ppval(pp,Ib);
%ind=find(abs(IVmeasure.ib-Ib)<1e-10);
%Vout=IVmeasure.vout(ind);
%[I0,V0]=GetIVTES(Vout,Ib,Rf);
IVaux.ibias=Ib;
IVaux.vout=Vout;
IVaux.Tbath=IVmeasure.Tbath;
IVstruct=GetIVTES(Circuit,IVaux);%%%

I0=IVstruct.ites;
V0=IVstruct.vtes;

%R0=0.46*Rn;%0.0147;
%T0=145e-3;
%V0=0.507e-6;I0=43.78e-6;
P0=V0.*I0;
%G=716e-12;
R0=V0/I0;
%%%%%test
%G0=spline([TES.Gset.rp],[TES.Gset.G],R0/Rn)*1e-12
%T0=spline([TES.Gset.rp],[TES.Gset.Tc],R0/Rn)
%pause(1)
%R0/Rn

rp=p;
%rp(3)=abs(rp(3));
if(length(p)==3)
        %derived parameters
        %for simple model p(1)=Zinf, p(2)=Z0, p(3)=taueff
        %rp=real(p);
        %El orden importa a la hora de exportar los datos.
        param.rp=R0/Rn;
        param.L0=(rp(2)-rp(1))/(rp(2)+R0);
        param.ai=param.L0*G0*T0/P0;
        param.bi=(rp(1)/R0)-1;
        param.tau0=rp(3)*(param.L0-1);
        param.taueff=rp(3);
        param.C=param.tau0*G0;        
        param.Zinf=rp(1);
        param.Z0=rp(2);
        %%%%fixed C=1.2pJ/K.
        if (0)
            %C=1.2e-12;%%%%1.2e-12
            %C=0.75e-12;
            C=6.7e-15;%2Z4_64.
            %C=15e-15;%%%1Z11_46A
            param.rp=R0/Rn;            
            param.Zinf=rp(1);
            param.Z0=rp(2);
            param.taueff=rp(3);
            param.tau0=C/G0;
            param.L0=C/(G0*param.taueff)-1;%%%OJO AL SIGNO
            param.ai=param.L0*G0*T0/P0;
            param.bi=(rp(1)/R0)-1;
            param.C=C;
        end
    elseif(length(p)==4)%%%1TB con reactancia.
        %derived parameters
        %for simple model p(1)=Zinf, p(2)=Z0, p(3)=taueff
        %rp=real(p);
        %El orden importa a la hora de exportar los datos.
        param.rp=R0/Rn;
        param.L0=(rp(2)-rp(1))/(rp(2)+R0);
        param.ai=param.L0*G0*T0/P0;
        param.bi=(rp(1)/R0)-1;
        param.tau0=rp(3)*(param.L0-1);
        param.taueff=rp(3);
        param.C=param.tau0*G0;        
        param.Zinf=rp(1);
        param.Z0=rp(2);
        param.Lt=p(4);
     
    elseif(length(p)==5)
        %derived parameters for 2 block model case A
        param.rp=R0/Rn;
        param.bi=(rp(1)/R0)-1;  
        param.Zinf=p(1);
        param.Z0=p(2);
        param.t_1=p(5);
        param.geff=p(4);%%%gt1/((gt1+gtb)(L-1))
        param.taueff=rp(3);
        param.L=(p(2)-p(1))*(1+p(4))/((R0+p(1))+(p(2)-p(1))*(1+p(4)));%%%Esto es com�n a todos los modelos
        
        %%%Hanging Model
        %%%si gtb=GIV=G0:
        param.g_1=G0*(1/(1-p(4)*(param.L-1))-1);
        param.C=p(3)*(param.L-1)*(param.g_1+G0);
        param.C_1=p(5)*param.g_1;
        param.ai=param.L*T0*(param.g_1+G0)/P0;    
        param.tau0=param.C/G0;
        param.L0=param.L;

    elseif(length(p)==7)
        param=nan;
end



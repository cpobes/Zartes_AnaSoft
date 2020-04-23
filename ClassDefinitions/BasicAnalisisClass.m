classdef BasicAnalisisClass < handle
    %%%Wrapper Class para encapsular la estructura devuelta por AnalizaRun
    %%%junto con funciones para acceder a la estructura, pintar los datos y
    %%%reanalizarlos.
    properties
        datadir=[];
        structure=[];%%%Estructura global, incluye las IVset, TES, P, etc.
        analizeOptions=[];
        NoisePlotOptions=BuildNoiseOptions;
        Zfitmodel=[];%%%El modelo con el que se analizaron los datos.
        Zfitboolplot=0;%%%booleano por si quiero pintar o no los resultados del reanálisis.
        auxFitstruct=[];%%%Guardo los resultados de reanalisis en una nueva estructura para poder trabajar con ella.
        auxSingleFitStruct=[];
    end
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=BasicAnalisisClass(TES_data_str)
            obj.structure=TES_data_str;
            obj.datadir=TES_data_str.analizeOptions.datadir;
            obj.analizeOptions=TES_data_str.analizeOptions;
            obj.Zfitmodel=TES_data_str.analizeOptions.ZfitOpt.ThermalModel;
            obj.auxFitstruct=TES_data_str.P;%inicializo la auxFitstruct a la estructura original.(para bias positivos).
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Plot functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotParameter(obj,Temp,x_str,y_str,varargin)
            %[~,mP]=GetTbathIndex(Temp,obj.structure);
            %paux=obj.structure.P(mP);
            paux=obj.GetPstruct(Temp);
            if nargin==5%%%soreescribimos la P original.
%                 if isstruct(varargin{1})
%                     paux=varargin{1};
%                 else
%                     paux=obj.auxFitstruct;
%                 end
                paux=obj.GetPstruct(Temp,varargin{1});
            end
            plotParamTES(paux,x_str,y_str)
        end
        function plotZs(obj,Temp,rps,varargin)
            auxstruct=obj.structure;
            if nargin==4
                paux=obj.GetPstruct(Temp,varargin{1});
                auxstruct.P=paux;
            end
            plotZ_Tb_Rp(auxstruct,rps,Temp)
        end
        function plotNoises(obj,Temp,rps)
            plotnoiseTbathRp(obj.structure,Temp,rps,obj.NoisePlotOptions)
        end
        function plotFunctionFromParameters(obj,Temp,paramList,fhandle,varargin)
            %%%Funcion para pintar una funcion arbitraria de los parametros
            %%%de analisis frente a %Rn.
            
            if nargin==4 %isempty(varargin)
                paux=obj.GetPstruct(Temp);
            else %if nargin==5%%%soreescribimos la P original.
                if isstruct(varargin{1})
                    'pnew'
                    paux=varargin{1};
                else
                    'paux'
                    paux=obj.auxFitstruct;
                end
            end
            %paux
            rps=[obj.GetPstruct(Temp,paux).p.rp];
            fpar=obj.GetFunctionFromParameters(Temp,paramList,fhandle,paux);
            plot(rps,fpar,'.-')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Get functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Tc=GetTc(obj)
           Tc=obj.structure.TES.Tc; 
        end
        function Rn=GetRn(obj)
           Rn=obj.structure.TES.Rn; 
        end
        function param=GetFittedParameterByName(obj,Temp,rps,name,varargin)
            if nargin==4%isempty(varargin)
                paux=obj.GetPstruct(Temp);
            else
                paux=obj.GetPstruct(Temp,varargin{1});%%%Podemos pasar una nueva estructura P o el auxFitstruct.
            end
            rtes=GetPparam(paux.p,'rp');
            [~,jj]=min(abs(bsxfun(@minus, rtes', rps)));
            param=GetPparam(paux.p,name);
            actualRps=rtes(jj)
            param=param(:,jj);%%%Esto devuelve matriz para el p0 y el parray.
        end
        function IV=GetIV(obj,Temp)
            [mIV,~]=GetTbathIndex(Temp,obj.structure);
            IV=obj.structure.IVset(mIV);
        end
        function P=GetPstruct(obj,Temp,varargin)
            if nargin==3%%%soreescribimos la P original.
                if isstruct(varargin{1})
                    'pnew'
                    paux=varargin{1};
                else
                    'paux'
                    paux=obj.auxFitstruct;
                end
            else
                'pold'
                paux=obj.structure.P;
            end
            [~,mP]=GetTbathIndex(Temp,obj.structure.IVset,paux);%%%Usamos el formato en que se pasa IVset y Pset
            P=paux(mP);
        end
        function Ibias=GetIbias(obj,Temp,Rp)
            IV=obj.GetIV(Temp);
            Ibias=BuildIbiasFromRp(IV,Rp)*1e-6;%%%Ojo, BuildIbias devuelve uA.
        end
        function param=GetParameterFromFit(obj,Temp,Rp,pfit)
            %%%Si refiteo los datos necesito recalcular la estructura param
            %%% Función para 1 Rp único. Si no, tendría que pasar también
            %%% pfit como matriz.
                TES=obj.structure.TES;
                Circuit=obj.structure.circuit;
                IVmeasure=obj.GetIV(Temp);
                modelname.model=obj.Zfitmodel;             
                Ib=BuildIbiasFromRp(IVmeasure,Rp)*1e-6;%%%Ojo, BuildIbias devuelve uA.
                param=GetModelParameters(pfit,IVmeasure,Ib,TES,Circuit,modelname);
        end
        function fpar=GetFunctionFromParameters(obj,Temp,paramList,fhandle,varargin)
            %%%paramList es un cellarray con los nomrbes de los parametros
            %%%fhandle es un handle a la definicion de la funcion que se
            %%%quiere ejecutar sobre los parametros. fhandle(p) con
            %%%p_i=p(i,:). Se asumen los rps de la estructura P.
            if nargin==4
                paux=obj.GetPstruct(Temp);
            else
                paux=obj.GetPstruct(Temp,varargin{1});
            end
            rps=[paux.p.rp];
            for i=1:numel(paramList)
                p(i,:)=obj.GetFittedParameterByName(Temp,rps,paramList{i},paux);
            end
            fpar=fhandle(p);
        end
        function actualrps=GetActualRps(obj,Temp,rps,varargin)
            %Devuelve los %Rn más cercanos a los que realmente se tienen
            %datos de Z(w) en la estructura P.
            if nargin==3
                p=obj.GetPstruct(Temp).p;
            else
                p=obj.GetPstruct(Temp,varargin{1}).p;
            end
            rtes=GetPparam(p,'rp');
            [~,jj]=min(abs(bsxfun(@minus, rtes', rps)));
            actualrps=rtes(jj);
        end
        function Zfiles=GetZfilenames(obj,Temp,rps,varargin)
            %[mIV,~]=GetTbathIndex(Temp,obj.structure);
            ivaux=obj.GetIV(Temp);
            olddir=pwd;
            %podemos pasar 'PXI_TF_*' para cargar las TF de la PXI. Si se
            %llama obj.GetZfilenames(temp,rps) el nargin sigue siendo 3.
            if nargin==3 str='\TF_*'; else str=varargin{1};end 
            cd(obj.datadir)%ojo, GetFilesFromRp solo funciona desde el directorio de datos.
            Zfiles=GetFilesFromRp(ivaux,Temp,rps,str);
            cd(olddir)
        end
        function Ztes=GetZtesData(obj,Temp,rps)
            olddir=pwd;
            cd(obj.datadir);
            %%%
            Tdir=GetDirfromTbath(Temp);
            zfiles=obj.GetZfilenames(Temp,rps);
            zfullpath=strcat(Tdir,'\',zfiles);
            tfdata=importTF(zfullpath);
            %%%hay que hacer buble porque GetZfromTF sólo admite una tf en
            %%%distintos formatos.
            for i=1:numel(tfdata) Ztes(i)=GetZfromTF(tfdata{i},obj.structure.TFS,obj.structure.circuit); end
            %%% devolvemos array de estructuras con las Ztes.
            cd(olddir);
        end
        %%%Implementar Idem para Noise Files.
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Set functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=SetAuxFitstruct(obj,Pnew)
            obj.auxFitstruct=Pnew;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Fitting functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Pfit=BasicZfit(obj,Temp,rps)
            modelname=obj.Zfitmodel;
            model=BuildThermalModel(modelname);
            fitfunc=model.function;
            p0=model.X0;
            LB=model.LB;
            UB=model.UB;
            for jj=1:length(Temp)
            ZtesData=GetZtesData(obj,Temp(jj),rps);
            ind_z=1:length(ZtesData(1).f);%%%De momento cogemos todas las freqs.
            fS=ZtesData(1).f;
            ind_z=find((fS>5e0 & fS<=40e3) |(fS>40e3 & fS<90e3));%%sobreescribimos ind_z
            %p0=[13.1123   -6.3463    0.0129   15.6265    0.2505]*1e-3;%sobreescribimos p0
            %p0=[0.0145 -0.0097 1.7949e-05 0.0221 2.2182e-04]
            p0=obj.GetFittedParameterByName(Temp(jj),rps(1),'parray');%empiezo con el parray viejo del primer punto.
            for i=1:numel(ZtesData)
                XDATA=ZtesData(i).f(ind_z);                
                YDATA=medfilt1([real(ZtesData(i).tf(ind_z)) imag(ZtesData(i).tf(ind_z))],1);
                p0_old=obj.GetFittedParameterByName(Temp(jj),rps(i),'p0');
                if i>1 p0=obj.auxSingleFitStruct.parray;end%%%Usamos como p0 el p del punto anterior.
%                 %debug1
%                 paux=[0.0151  -0.011386   0.0000211311   0.0526   0.000192];
%                 tt0=[paux(3) paux(5)];
%                 fitaux=@(tt,f)fitfunc([paux(1) paux(2) tt(1) paux(4) tt(2)],f)
%                 [tt,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitaux,tt0,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
%                 p=[paux(1) paux(2) tt(1) paux(4) tt(2)]
                %f_debug1
                %%%double_fit
                %[p,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitfunc,p0,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
                %%%Prueba. refit con pout como nuevo p0.
                %[p,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitfunc,p,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
                %%%f_double_fit
                            %%%%%%Weighted Fitting Method.            
                            %weight=sqrt((XDATA));                            
                            w=2*pi*XDATA;tI=p0_old(3);
                            %weight=2*w./(1+(w*tI).^2);%%%Pesamos igualmente cada sector del semicírculo.
                            weight=1;
                            costfunction=@(p)weight.*sqrt(sum((fitfunc(p,XDATA)-YDATA).^2,2));
                            [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p0,LB,UB);%%%uncomment for real parameters.
                            n_iter=5;
                            for iter=1:n_iter
                                [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p,LB,UB);%%%uncomment for real parameters.
                            end
                            %%%f_weighted_fit
                ci = nlparci(p,aux2,'jacobian',auxJ);
                resN= aux1;
                %%%Salvamos fit con formato de Estructura
                paux=obj.GetParameterFromFit(Temp(jj),rps(i),p);
                if i==1 Pfit(jj).p=paux;end%%%en la primera iteracion no existe Pfit.
                Pfit(jj).p(i)=Pfit(jj).p(1);%%%después necesitamos crear el siguiente indice antes de llamar a UpdateStruct, si no, no existe.
                Pfit(jj).p(i)=UpdateStruct(Pfit(jj).p(i),paux);%%%paux no contiene p0
                Pfit(jj).p(i).p0=p0;
                Pfit(jj).residuo(i).ci=ci;
                Pfit(jj).residuo(i).resN=resN;
                Pfit(jj).residuo(i).d2=sum(((p0-p)./p0).^2);%%%Suma de diferencias relativas al cuadrado como medida del cambio en 'p'.
                Pfit(jj).rps(i)=obj.GetActualRps(Temp(jj),rps(i));
                if Temp(jj)>1 Pfit(jj).Tbath=Temp(jj)*1e-3; else Pfit(jj).Tbath=Temp(jj);end;
                obj.auxSingleFitStruct=Pfit(jj).p(i);%%%guardamos en esa estructura el resultado de cada fit individual.
                if obj.Zfitboolplot
                    scale=1;
                    %plot(ZtesData(i).tf(ind_z)*scale,'.-'),ylabel('ImZ(m\Omega)');xlabel('ReZ(m\Omega)');
                    plot(YDATA(:,1)*scale,YDATA(:,2)*scale,'.-'),ylabel('ImZ(m\Omega)');xlabel('ReZ(m\Omega)');
                    hold on,grid on
                    plot(model.Cfunction(p,XDATA)*scale,'-r')
                    set(gca,'fontsize',12)
                    figure
                    semilogx(fS(ind_z),YDATA(:,1),'.-'),hold on
                    semilogx(fS(ind_z),YDATA(:,2),'.-'),
                end%end_if
            end
            end%end_for_jj
            obj.SetAuxFitstruct(Pfit);%%%<-! Hay que derivar la clase de handle para que funcione!
        end
    end
end
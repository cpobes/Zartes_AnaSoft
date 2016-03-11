function IVmeasure=BuildIVmeasureStruct(data,Tbath)
%%Creamos la estructura de medida para usar con el resto de funciones.

  IVmeasure.ibias=data(:,1);%%%
  IVmeasure.voutc=data(:,2);%%%
  IVmeasure.Tbath=Tbath;

function ztes= GetZfromTF( tf, TFS, circuit )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if isstruct(tf)
    tfaux=tf.tf;
    f=tf.f;
else
    tfaux=tf(:,2)+1i*tf(:,3);
    f=tf(:,1);
end

if isstruct(TFS)
    tfsaux=TFS.tf;
else
    tfsaux=TFS(:,2)+1i*TFS(:,3);
end

Rth=circuit.Rsh+circuit.Rpar+2*pi*circuit.L*f*1i;
ztes.tf=(tfsaux./tfaux-1).*Rth;
ztes.f=f;

end


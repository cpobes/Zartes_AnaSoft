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

tfauxHandle=@(x) interp1(f,tfaux,x);
if isstruct(TFS)
    tfsaux=TFS.tf;
    fS=TFS.f;
else
    tfsaux=TFS(:,2)+1i*TFS(:,3);
    fS=TFS(:,1);
end
tfsauxHandle=@(x) interp1(fS,tfsaux,x);

RthHandle=@(x) circuit.Rsh+circuit.Rpar+2*pi*circuit.L*x*1i;
ztesHandle=@(x) (tfsauxHandle(x)./tfauxHandle(x)-1).*RthHandle(x);
%ztes.tf=(tfsaux./tfaux-1).*Rth;
ztes.tf=ztesHandle(f);
ztes.f=f;

end


function J=rgb2srgb(I)
t=0.003138;
f=0.055;
gama=1/2.4;
s=12.92;
J=zeros(size(I));
J(I<=t)=s*I(I<=t);
J(I>t)=(1+f).*I(I>t).^gama-f;

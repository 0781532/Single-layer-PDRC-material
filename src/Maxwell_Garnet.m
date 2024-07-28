function [W,N,K]=Maxwell_Garnet(mater_1,mater_2,f_1)

mate_1=[mater_1 '.txt'];
mate_2=[mater_2 '.txt'];
%2020/01/14 Note: f_1 is the mixing ratio of mate_1. The mixing ratio of
%mate_2 is 1-f_1.
NK0=load(mate_1); %母體
NK1=load(mate_2); %添加物
NK=load('Standard.txt'); %參考波長
% Interpolation use Si02's wavelength range to be standard one
% 
NK0= [NK(:,1) interp1(NK0(:,1), NK0(:,2), NK(:,1),'linear','extrap') interp1(NK0(:,1), NK0(:,3), NK(:,1),'linear','extrap')];
NK1= [NK(:,1) interp1(NK1(:,1), NK1(:,2), NK(:,1),'linear','extrap') interp1(NK1(:,1), NK1(:,3), NK(:,1),'linear','extrap')];


% NK0= [NK interp1(NK0(:,1), NK0(:,2), NK,'linear','extrap') interp1(NK0(:,1), NK0(:,3), NK,'linear','extrap')];
% NK1= [NK interp1(NK1(:,1), NK1(:,2), NK,'linear','extrap') interp1(NK1(:,1), NK1(:,3), NK,'linear','extrap')];

%2020/01/14 revise  interpolation  method to gain a reasonable result

Eps0=[NK0(:,1),complex(NK0(:,2).^2-NK0(:,3).^2,2*NK0(:,2).*NK0(:,3))];
Eps1=[NK1(:,1),complex(NK1(:,2).^2-NK1(:,3).^2,2*NK1(:,2).*NK1(:,3))];

f2=1-f_1;
f=[f_1 f2];
Eb=Eps0(:,2);
Eps=Eps1(:,2);

Esum=zeros(size(Eps0(:,1)));
Esum=Esum+f(2)*(Eps-Eb)./(Eps+Eb*2);
Eeff=(2*Esum+1)./(1-Esum).*Eb;

N=sqrt(0.5*(abs(Eeff)+real(Eeff)));
K=sqrt(0.5*(abs(Eeff)-real(Eeff)));
W=NK0(:,1);

end




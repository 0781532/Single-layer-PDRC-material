function [W,N,K]=Maxwell_Garnet_3(mater_1,mater_2,mater_3,f_1,f_2,f_3)
mate_1=[mater_1 '.txt'];
mate_2=[mater_2 '.txt'];
mate_3=[mater_3 '.txt'];
NK0=load(mate_1); %母體
NK1=load(mate_2); %添加物
NK2=load(mate_3); %添加物
NK=load('Standard.txt'); 

NK0= [NK(:,1) interp1(NK0(:,1), NK0(:,2), NK(:,1),'linear','extrap') interp1(NK0(:,1), NK0(:,3), NK(:,1),'linear','extrap')];
NK1= [NK(:,1) interp1(NK1(:,1), NK1(:,2), NK(:,1),'linear','extrap') interp1(NK1(:,1), NK1(:,3), NK(:,1),'linear','extrap')];
NK2= [NK(:,1) interp1(NK2(:,1), NK2(:,2), NK(:,1),'linear','extrap') interp1(NK2(:,1), NK1(:,3), NK(:,1),'linear','extrap')];

Eps0=[NK0(:,1),complex(NK0(:,2).^2-NK0(:,3).^2,2*NK0(:,2).*NK0(:,3))];
Eps1=[NK1(:,1),complex(NK1(:,2).^2-NK1(:,3).^2,2*NK1(:,2).*NK1(:,3))];
Eps2=[NK2(:,1),complex(NK2(:,2).^2-NK2(:,3).^2,2*NK2(:,2).*NK2(:,3))];

f=[f_1 f_2 f_3];
Eb=Eps0(:,2);
Eps1=Eps1(:,2);
Eps2=Eps2(:,2);
Esum=zeros(size(Eps0(:,1)));
Esum=Esum+f(2)*(Eps1-Eb)./(Eps1+Eb*2)+f(3)*(Eps2-Eb)./(Eps2+Eb*2);
Eeff=(2*Esum+1)./(1-Esum).*Eb;
N=sqrt(0.5*(abs(Eeff)+real(Eeff)));
K=sqrt(0.5*(abs(Eeff)-real(Eeff)));
W=NK0(:,1);


end




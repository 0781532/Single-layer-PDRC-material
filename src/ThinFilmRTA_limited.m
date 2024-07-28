function [ABC]=ThinFilmRTA(wl,N,K,T1)
%------------------------------
Nm=1;                             %環境折射率，空氣=1
Nsub=load('Substrate.txt');   %基板折射率，Substrate.xlsx

Nsub=[wl interp1(Nsub(:,1), Nsub(:,2), wl,'linear','extrap') interp1(Nsub(:,1), Nsub(:,3), wl,'linear','extrap')];
%-----------------------------
% T1=100:100:100;        %膜厚，單位是nm，可以輸入一個系列的數字
%-----------------------------


wave=wl;
n1=N;
k1=K;

N1=complex(n1,-k1);
Nsub=complex(Nsub(:,2),-Nsub(:,3));
%-----------------------------
%-----------------------------
R=zeros(size(wave,1),size(T1,2));

for w=1:size(wave,1)
    for t=1:size(T1,2)             
             del1=2*pi./wave(w).*T1(t).*N1(w);
             admi1=N1(w);
             
             if imag(del1)<-700
                 del1=complex(real(del1),-700);
             end
             
             M1=[cos(del1),1i*sin(del1)./admi1;1i*sin(del1).*admi1,cos(del1)];
             Mm=[1;Nsub(w)];
             Ma=M1*Mm;
             Y=Ma(2)/Ma(1);
             R(w,t)=((Nm-Y)/(Nm+Y))*((Nm-Y)/(Nm+Y))';    
             T(w,t)=4*Nm*real(Nsub(w))/((Nm*Ma(1)+Ma(2))*(Nm*Ma(1)+Ma(2))');

    end
end
R=R;
T=T;
A=1-R;
ABC= [wave N K R T A];
% clearvars -except wave R T A

end


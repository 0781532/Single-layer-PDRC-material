function [FINAL,FullAbsorption,Psun,Patm,Prad]=Pcool_Tequ_mix_3(mater_1,mater_2,mater_3,f_1,f_2,f_3,hcon,Tamb,Tdev,Pheating,T1)
[wl,N,K]=Maxwell_Garnet_3(mater_1,mater_2,mater_3,f_1,f_2,f_3);  % Calculate n,k for mix by using Maxwell_Garnet funtion
[ABC]=ThinFilmRTA_limited(wl,N,K,T1);       % Calculate R,T,A for mix by using ThinFilmRTA function

PAM15G=load('AM1.5G.txt');
Tatm=load('Atmosphere T reduced by 1000 10mm_new.txt');
TRA=ABC;
FullAbsorption=TRA;


Wavelength=Tatm(:,1);
UnitofPi=pi/60;
theta=[0:UnitofPi:(pi/2-UnitofPi)];


theta2=repmat(theta,length(Wavelength),1);



Absorption_Vis=interp1(FullAbsorption(:,1), FullAbsorption(:,6), PAM15G(:,1),'nearest');
Device_absorption=interp1(FullAbsorption(:,1), FullAbsorption(:,6), Wavelength,'nearest');
Wdiff=diff(PAM15G(:,1));
Wdiff=[Wdiff;0.005];

Psun=sum(Absorption_Vis.*PAM15G(:,2).*Wdiff)*1000;
Iamb=Ibb(Wavelength*10^-6,Tamb);

for m=1:length(Tdev)
Idev=Ibb(Wavelength*10^-6,Tdev(m));

Tatm2=repmat(Tatm(:,2),1,length(theta));
Emissitivity_Atm=1-Tatm2.^(1./cos(theta2));
Device_absorption_angle=repmat(Device_absorption,1,length(theta));
Emissitivity_Atm_sum=sum(Emissitivity_Atm.*cos(theta2).*sin(theta2),2)*UnitofPi;
Device_absorption_angle_sum=sum(Device_absorption_angle.*cos(theta2).*sin(theta2),2)*UnitofPi;
dW=[diff(Wavelength) ;0]*10^-6;
Patm=2*pi*sum(Iamb.*Emissitivity_Atm_sum.*Device_absorption.*dW);
Emissitivity_Atm_sum=sum(Emissitivity_Atm.*cos(theta2).*sin(theta2),2)*UnitofPi;
Prad=2*pi*sum(Idev.*Device_absorption_angle_sum.*dW);
Pcon=hcon*(Tamb-Tdev(m));
Pnet=Prad-Patm-Pcon-Psun-Pheating;


Patm_total_for_Tdev(m)=Patm;
Pnet_total_for_Tdev(m)=Pnet;
Prad_total_for_Tdev(m)=Prad;
Pcon_total_for_Tdev(m)=Pcon;

if Tdev(m)==Tamb
Patm_amb=Patm;
Pnet_amb=Pnet;
Prad_amb=Prad;
Pcon_amb=Pcon;
end
end


Pnet_total=zeros(length(Tdev),1);
Prad_total=zeros(length(Tdev),1);
Pcon_total=zeros(length(Tdev),1);
Patm_total=zeros(length(Tdev),1);
Patm_total(:,1)=Patm_total_for_Tdev';
Pnet_total(:,1)=Pnet_total_for_Tdev';
Prad_total(:,1)=Prad_total_for_Tdev';
Pcon_total(:,1)=Pcon_total_for_Tdev';


for o=1:(length(Tdev)-1)
    if Pnet_total(o,1)*Pnet_total(o+1,1) <= 0
        Tequ=interp1(Pnet_total(o:(o+1),1),Tdev(o:(o+1)),0,'linear');
        Prad_equ(1)=interp1(Pnet_total(o:(o+1),1),Prad_total_for_Tdev(o:(o+1)),0,'linear');
        Pcon_equ(1)=interp1(Pnet_total(o:(o+1),1),Pcon_total_for_Tdev(o:(o+1)),0,'linear');
        Pnet_equ(1)=interp1(Pnet_total(o:(o+1),1),Pnet_total_for_Tdev(o:(o+1)),0,'linear');
        break   

    end
    
end
    

   
Ibb_equ=Ibb(Wavelength*10^-6,Tequ(1));
Pnet_total2=[Tdev Pnet_total];
Prad_total2=[Tdev Prad_total];
Patm_total2=[Tdev Patm_total];
Pcon_total2=[Tdev Pcon_total];

Pnet_total3(1,:)=Pnet_total;

% FOM_list(R,[1:6])={Tequ Pnet_amb Psun Patm Prad_amb};


Pnet_total=[Tdev Pnet_total3'];

Final= [Tequ Pnet_amb];


ddd=max([length(TRA) length(Tequ) length(Pnet_amb) length(Psun) length(Patm) length(Prad_amb) length(T1)]);

Teq1=[Tequ;zeros(ddd-length(Tequ),1)];
Pnet_amb1=[Pnet_amb;zeros(ddd-length(Pnet_amb),1)];
Psun1=[Psun;zeros(ddd-length(Psun),1)];
Patm1=[Patm;zeros(ddd-length(Patm),1)];
Prad_amb1=[Prad_amb;zeros(ddd-length(Prad_amb),1)];
T11=[T1;zeros(ddd-length(T1),1)];

FINAL=[TRA Teq1 Pnet_amb1 Psun1 Patm1 Prad_amb1];

% matrix1=[{'Al'};{'Al2O3'} ;{'Au'}; {'Be'}; {'C(graphine)'}; {'C(thin film)'};{'CsBr'}; {'CsI'};{'Fe2O3'}; {'Fe3O4'}; {'KCl'}; {'Mn'}; {'NaCl'}; {'SiC (cubic)'}; {'SiO2_amorphous'}; {'SiO2_crystal'}; {'SiO2'}; {'SrF2'}; {'TiO2'}; {'ZnO'}; {'ZnS'}; {'Zr'}; {'PDMS_C2H6OSi'}; {'Silk'}; {'Ps'}; {'PMMA'}; {'KBr'}; {'Bn'}; {'Si3N4'}; {'ratio_1'}; {'ratio_2'}; {'Thickness'} ] ; 
% matrix2 =zeros(32,1);
% fid = fopen( 'matrix.csv', 'w' );
% for jj = 1 : length( matrix1 )
%     fprintf( fid, '%s,%d\n', matrix1{jj}, matrix2(jj) );
% end
% fclose( fid );



end



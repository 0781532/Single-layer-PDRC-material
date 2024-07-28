clear all;
clc;
tic
%m1=[{'Al'} {'Al2O3'} {'Au'} {'Be'} {'C(graphine)'} {'C(thin film)'} {'Cr'} {'CsBr'} {'CsI'} {'Cu'} {'Fe'} {'Fe2O3'} {'Fe3O4'} {'KCl'} {'Lu'} {'Mn'} {'Mo'} {'NaCl'} {'SiC'}  {'SiO2'} {'SrF2'} {'Ti'} {'TiO2'} {'ZnO'} {'ZnS'} {'Zr'}] ; 
%m2=m1;
m1=[ {'Al'} {'Al2O3'}] ; 
m2=m1;

[d1,d2]=size(m1);
f=[1];  % % 1st material's thickness --> 2nd material'sthickness = 1-f_1
Thick=[1 1];%load('Thickness.txt');   (um)                                     
Thick1=Thick';                                       
                                         
hcon=10;            %���ҶǾɾɫY��W/m2/K
Tamb=300;           %�Ƿ�
Tdev=[250:1:400]';  %[�_�l�ū�:�ū׶��j:�פ�ū�]
Pheating=0;         %���ҥ[���\�v�A�p�q�l���󵥵�  W/m2
count=3;

for i=1:1
    f_1=f(i);
    f_2=1-f_1;      
    
    for i_1=1:d2
    T2=Thick1(i_1,:);  
    for i_2=1:d2
    if i_1==i_2
        continue
    end
    mater_1=cell2mat(m1(1,i_1));    % 1st material
    mater_2=cell2mat(m2(1,i_2));   % 2st material
    for i_3=1:length(T2)
        try
    T1=T2(i_3);
[FINAL,FullAbsorption]=Pcool_Tequ_mix_2(mater_1,mater_2,f_1,hcon,Tamb,Tdev,Pheating,T1);
count=count+1;
file_name=[num2str(count) '.Mix_' num2str(T1) '_' mater_1 '_' num2str(f_1) '_' mater_2 '_' num2str(f_2) '.csv'];
csvwrite(file_name,FINAL);
    catch
    disp('An error occurred while retrieving information from the internet.');
    disp('Execution will continue.');
  end

    end
    end
    end
    end
toc
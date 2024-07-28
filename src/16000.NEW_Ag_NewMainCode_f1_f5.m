clear all;
clc;
tic
%m1=[{'Al'} {'Al2O3'} {'Au'} {'Be'} {'C(graphine)'} {'C(thin film)'} {'Cr'} {'CsBr'} {'CsI'} {'Cu'} {'Fe'} {'Fe2O3'} {'Fe3O4'} {'KCl'} {'Lu'} {'Mn'} {'Mo'} {'NaCl'} {'SiC'}  {'SiO2'} {'SrF2'} {'Ti'} {'TiO2'} {'ZnO'} {'ZnS'} {'Zr'}] ; 
%m2=m1;
% m1=[{'Al'} {'Al2O3'} {'Au'} {'Be'} {'C(graphine)'} {'C(thin film)'} {'Cr'} {'CsBr'} {'CsI'} {'Cu'} {'Fe'} {'Fe2O3'} {'Fe3O4'} {'KCl'} {'Lu'} {'Mn'} {'Mo'} {'NaCl'} {'SiC (cubic)'}  {'SiO2_amophorous'}  {'SiO2_crystal'} {'SiO2'} {'SrF2'} {'Ti'} {'TiO2'} {'ZnO'} {'ZnS'} {'Zr'} {'PDMS_C2H6OSi'} {'DMMP_C3H9O3P'} {'DIMP_C7H17O3P'}] ; 
m1=[{'CsI'} {'DMMP_C3H9O3P'} ];
m2=m1;

[d1,d2]=size(m1);
f=[0.5 0.525 0.55 0.75 0.6 0.625 0.65 0.675 0.7 0.725 0.75 0.775 0.80 0.825 0.85 0.875 0.90 0.925 0.95 0.975];  % % 1st material's thickness --> 2nd material'sthickness = 1-f_1
  % % 1st material's thickness --> 2nd material'sthickness = 1-f_1
Thick=load('Thickness.txt');                                       
Thick1=Thick';   
d4=length(Thick1);
                                         
hcon=10;            %環境傳導導係數W/m2/K
Tamb=300;           %室溫
Tdev=[250:1:400]';  %[起始溫度:溫度間隔:終止溫度]
Pheating=0;         %環境加熱功率，如電子元件等等  W/m2
count=0;

for i=1:5
    f_1=f(i);
    f_2=1-f_1;      
    
    for i_1=1:2
       T2=Thick1(i_1,:);  
       for i_2=1:2
         if i_1==i_2
           continue
         end
           mater_1=cell2mat(m1(1,i_1));    % 1st material
           mater_2=cell2mat(m2(1,i_2));    % 2st material
         for i_3=1:4:length(T2)
          try
            T1=T2(i_3);
            [FINAL,FullAbsorption]=Pcool_Tequ_mix_2(mater_1,mater_2,f_1,hcon,Tamb,Tdev,Pheating,T1);
            count=count+1;
%             file_name=[ '\\140.113.20.110\data\EF755\personal backup\Ballin\1. Le to Bo-ying\Ag_Subtrate_All_Data_20200411\' num2str(count) '.Mix_' num2str(T1) '_' mater_1 '_' num2str(f_1) '_' mater_2 '_' num2str(f_2) '.csv'];
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
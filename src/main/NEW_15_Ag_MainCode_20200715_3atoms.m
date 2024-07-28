clear all;
clc;
tic
m1=[{'Al'} {'Al2O3'} {'Au'} {'Be'} {'C(graphine)'} {'C(thin film)'} {'CsBr'} {'CsI'} {'Fe2O3'} {'Fe3O4'} {'KCl'} {'Mn'} {'NaCl'} {'SiC (cubic)'} {'SiO2_amorphous'} {'SiO2_crystal'} {'SiO2'} {'SrF2'} {'TiO2'} {'ZnO'} {'ZnS'} {'Zr'} {'PDMS_C2H6OSi'} {'Silk'} {'Ps'} {'PMMA'} {'KBr'} {'hBN_isotropic'} {'Si3N4'}  {'BaF2'} {'CaF2'}] ; 
m2=m1;
m3=m2;
% m2=[{'Silk'}] ; 
% m1=[{'CsI'} {'DMMP_C3H9O3P'} ];
% m2=m1;

[d1,d2]=size(m1);
%% Calculate the number of mix rate of 3 materials
f=[0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95];
f_2=[0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45];
f_3=[0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ];
dd1=length(f);
dd2=length(f_2);
dd3=length(f_3);
fff2=[];
for bn=1:dd1
    for bm=1:dd2
        for bp=1:dd3
    tt=f(bn)+f_2(bm)+f_3(bp);   

    
    if tt==1
    fff=[f(bn) f_2(bm) f_3(bp)];
    fff2=[fff2; fff];         
    end
        end
    end
end
ddd=length(fff2(:,1));
%% Thickness
% % 1st material's thickness --> 2nd material'sthickness = 1-f_1
Thick=load('Thickness3.txt');                                       
Thick1=Thick';   
% Thick1=1000;
d4=length(Thick1);
%%  Environtment condition                                        
hcon=10;            %環境傳導導係數W/m2/K
Tamb=300;           %室溫
Tdev=[250:1:400]';  %[起始溫度:溫度間隔:終止溫度]
Pheating=0;         %環境加熱功率，如電子元件等等  W/m2

%% Run main program to calculate {R,T,A} and {Teq, Pcool}
count=0;

for i=1:ddd
    f_1=fff2(i,1);
    f_2=fff2(i,2); 
    f_3=fff2(i,3); 
    
    for i_1=1:d2
       T2=Thick1(i_1,:)./1000;  
       for i_2=1:d2
           for i_4=1:d2
         if i_1==i_2
           continue
         end
           mater_1=cell2mat(m1(1,i_1));    % 1st material
           mater_2=cell2mat(m2(1,i_2));    % 2nd material
           mater_3=cell2mat(m3(1,i_4));    % 3rd material
         for i_3=1:1:length(T2)
          try
            T1=T2(i_3);
            [FINAL,FullAbsorption]=Pcool_Tequ_mix_3(mater_1,mater_2,mater_3,f_1,f_2,f_3,hcon,Tamb,Tdev,Pheating,T1);
            
            count=count+1;
            kkk=zeros(1323,1);
            matrix1=[{'Al'};{'Al2O3'} ;{'Au'}; {'Be'}; {'C(graphine)'}; {'C(thin film)'};{'CsBr'}; {'CsI'};{'Fe2O3'}; {'Fe3O4'}; {'KCl'}; {'Mn'}; {'NaCl'}; {'SiC (cubic)'}; {'SiO2_amorphous'}; {'SiO2_crystal'}; {'SiO2'}; {'SrF2'}; {'TiO2'}; {'ZnO'}; {'ZnS'}; {'Zr'}; {'PDMS_C2H6OSi'}; {'Silk'}; {'Ps'}; {'PMMA'}; {'KBr'}; {'BN'}; {'Si3N4'}; {'BaF2'}; {'CaF2'}; {'ratio_1'}; {'ratio_2'} ; {'ratio_3'}; {'Thickness'}] ; 
            kn=[{'0'}];
            for kk=1:1323
            matrix1=[matrix1; kn];                       
            end
            
            matrix2 =zeros(1358,1);

            matrix2(i_1,1)=1;
            matrix2(i_2,1)=1;
            matrix2(i_4,1)=1;
            matrix2(32,1)=f_1;
            matrix2(33,1)=f_2;
            matrix2(34,1)=f_3;
            matrix2(35,1)=T1;
            Z1=FINAL(:,1);
            Z2=FINAL(:,2);
            Z3=FINAL(:,3);
            Z4=FINAL(:,4);
            Z5=FINAL(:,5);
            Z6=FINAL(:,6);
            Z7=FINAL(:,7);
            Z8=FINAL(:,8);
            Z9=FINAL(:,9);
            Z10=FINAL(:,10);
            Z11=FINAL(:,11);
            
            file_name=[ 'D:\NEW_DATA_20200715_3atoms_15\' num2str(count) '.Mix_' num2str(T1) '_' mater_1 '_' num2str(f_1) '_' mater_2 '_' num2str(f_2) '_' mater_3 '_' num2str(f_3) '.csv'];
           
            fid = fopen(file_name, 'w' );
             for jj = 1 : length( matrix1 )
               fprintf( fid, '%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n', matrix1{jj},matrix2(jj),Z1(jj),Z2(jj),Z3(jj),Z4(jj),Z5(jj),Z6(jj),Z7(jj),Z8(jj),Z9(jj),Z10(jj),Z11(jj));
             end
             fclose( fid );         
                        
%             file_name=[ 'D:\NEW_DATA_20200611\' num2str(count) '.Mix_' num2str(T1) '_' mater_1 '_' num2str(f_1) '_' mater_2 '_' num2str(f_2) '.csv'];
%             csvwrite(file_name,FINAL);

          catch
          disp('An error occurred while retrieving information from the internet.');
          disp('Execution will continue.');
          end
         end
           end
       end
    end
 end
toc
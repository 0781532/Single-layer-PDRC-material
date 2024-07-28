% fo = fopen('4.Mix_100000_ABC_0.5_ABC_0.5.csv');
% fprintf(fo,'%c',string1);
% fclose(fo);
% dlmwrite('4.Mix_100000_ABC_0.5_ABC_0.5.csv',data,'-append');
clear all;
clc;
% 
% matrix1 = {'water';'space';'fire'};
% matrix2 = [100;200;300];
% fid = fopen( 'matrix.csv', 'w' );
% for jj = 1 : length( matrix1 )
%     fprintf( fid, '%s,%d\n', matrix1{jj}, matrix2(jj) );
% end
% fclose( fid );

i_1=1;
i_2=3;
f_1=0.6;
T1=1000;

matrix1=[{'Al'};{'Al2O3'} ;{'Au'}; {'Be'}; {'C(graphine)'}; {'C(thin film)'};{'CsBr'}; {'CsI'};{'Fe2O3'}; {'Fe3O4'}; {'KCl'}; {'Mn'}; {'NaCl'}; {'SiC (cubic)'}; {'SiO2_amorphous'}; {'SiO2_crystal'}; {'SiO2'}; {'SrF2'}; {'TiO2'}; {'ZnO'}; {'ZnS'}; {'Zr'}; {'PDMS_C2H6OSi'}; {'Silk'}; {'Ps'}; {'PMMA'}; {'KBr'}; {'Bn'}; {'Si3N4'}; {'ratio_1'}; {'ratio_2'}; {'Thickness'} ] ; 
matrix2 =zeros(32,1);

matrix2(i_1,1)=1;
matrix2(i_2,1)=1;
matrix2(30,1)=f_1;
matrix2(31,1)=1-f_1;
matrix2(32,1)=T1;

matrix3 =zeros(32,1);
filename='m4.csv';

fid = fopen(filename, 'w' );
for jj = 1 : length( matrix1 )

    fprintf( fid, '%s,%d, %d\n', matrix1{jj}, matrix2(jj),matrix3(jj) );

end
fclose( fid );
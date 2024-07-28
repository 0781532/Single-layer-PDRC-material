clc
clear

tic
A=xlsread('Atmosphere-T-reduced-by-1000-10mm.xlsx');
toc
tic
B=csvread('Atmosphere-T-reduced-by-1000-10mm.txt.');
toc
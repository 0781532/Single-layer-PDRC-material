clear all;

clc;

f=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
f_2=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
f_3=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
dd=length(f);
count=0;
fff2=[];
for bn=1:dd
    for bm=1:dd
        for bp=1:dd
    tt=f(bn)+f_2(bm)+f_3(bp);    

    count=count+1;
    if tt==1
    fff=[f(bn) f_2(bm) f_3(bp)];
    fff2=[fff2; fff];         
    end
        end
    end
end
    
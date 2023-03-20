%索引从1开始，从列开始，一列一列的进行 数据类型 默认为double
clear,clc
rng default; 
A = randi(15,5);
B = A < 9; %逻辑矩阵（关系运算符）
C=A(B);
I=find(A<9); %返回符合条件数组索引的下标（单个下标）
D=A(I); %D=C
E=sum(sum(B)); %求A<9一共有几个数 sum(C) 求A<9元素的和

F=sum(A(:)) %求A的总和 
% A(isnan(A)) = 0; 将NaN替换为0
data=zeros(5,3,2)
data

%������1��ʼ�����п�ʼ��һ��һ�еĽ��� �������� Ĭ��Ϊdouble
clear,clc
rng default; 
A = randi(15,5);
B = A < 9; %�߼����󣨹�ϵ�������
C=A(B);
I=find(A<9); %���ط������������������±꣨�����±꣩
D=A(I); %D=C
E=sum(sum(B)); %��A<9һ���м����� sum(C) ��A<9Ԫ�صĺ�

F=sum(A(:)) %��A���ܺ� 
% A(isnan(A)) = 0; ��NaN�滻Ϊ0
data=zeros(5,3,2)
data

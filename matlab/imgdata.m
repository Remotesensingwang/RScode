clear
f=['H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\HY1C_COCTS_L1B_20210101T042500_baseTOA.tif'];
% [a,R]=geotiffread(f); %先导入投影信息
% info=geotiffinfo(f);

data=importdata(f);
data1=data(:,:,1);
data2=data(:,:,2);
data3=data(:,:,3);
data4=data(:,:,4);
data5=data(:,:,5);
data6=data(:,:,6);
data7=data(:,:,7);
data8=data(:,:,8);
f1=['H:\00data\FY3D\FY3D_dunhuang\tifout\2021\20210101_0625_TOA.tif'];
fy3ddata=importdata(f1);
fy3ddata8=fy3ddata(:,:,8);
fy3ddata9=fy3ddata(:,:,9);
fy3ddata10=fy3ddata(:,:,10);
fy3ddata11=fy3ddata(:,:,11);
fy3ddata12=fy3ddata(:,:,12);
fy3ddata14=fy3ddata(:,:,14);
fy3ddata15=fy3ddata(:,:,15);



min_1=min(min(data1));
max_1=max(max(data1));

% B = transpose(data); %如果IDL中没有进行矩阵转置，用这一行 
% s=reshape(data,[2048 2000 4]);
% m=s(:,:,1);
% M=transpose(m); 
% 
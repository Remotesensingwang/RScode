clear
% f=['D:\01研究生学习\05FY-3D数据\data\out\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_rs.tiff'];
 f=['D:\02FY3D\山建影像\sdjzimg.tif'];
% [a,R]=geotiffread(f); %先导入投影信息
% info=geotiffinfo(f);
data=importdata(f);
a=data(:,:,1)
b=(a>0)&(a<1)
c=a(b)
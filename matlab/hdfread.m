clear
% f=['D:\01�о���ѧϰ\05FY-3D����\data\out\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_rs.tiff'];
 f=['D:\02FY3D\ɽ��Ӱ��\sdjzimg.tif'];
% [a,R]=geotiffread(f); %�ȵ���ͶӰ��Ϣ
% info=geotiffinfo(f);
data=importdata(f);
a=data(:,:,1)
b=(a>0)&(a<1)
c=a(b)
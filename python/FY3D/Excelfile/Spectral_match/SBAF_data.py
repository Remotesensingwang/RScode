# coding=utf-8
import os
import pandas as pd
import numpy as np
import csv
from scipy.interpolate import interp1d
from glob import glob
# **************************************
# 对FY3D和MODIS前四个波段计算SBAF
# 首先进行插值，将Radcalnet站点的数据的TOA数值插值到光谱响应函数对应波段的TOA值
# 计算SBAF
# **************************************

# input_file = r'H:\00data\TOA\3D_MODIS_HY1C\FY3D_MODIS\RSF-copy.xlsx'
# radcalnet_filedir=r'C:\Users\lenovo\Downloads\Radcalnet_alldata\00'
# # *****************************Excel文件数据读取*****************************
# df_base= pd.read_excel(input_file,sheet_name='Sheet5')  # From an Excel file
#
# # *****************************FY3D*****************************
# rsf_FB1 =df_base['F-B1-band'][0:176].values
# rsf_FB1_value=df_base['F-B1-RSF'][0:176].values
#
# rsf_FB2 =df_base['F-B2-band'][0:174].values
# rsf_FB2_value=df_base['F-B2-RSF'][0:174].values
#
# rsf_FB3 =df_base['F-B3-band'][0:171].values
# rsf_FB3_value=df_base['F-B3-RSF'][0:171].values
#
# rsf_FB4 =df_base['F-B4-band'][0:195].values
# rsf_FB4_value=df_base['F-B4-RSF'][0:195].values
#
# # *****************************MODIS*****************************
# rsf_MB1 =df_base['M-B1-band'][0:101].values
# rsf_MB1_value=df_base['M-B1-RSF'][0:101].values
#
# rsf_MB2 =df_base['M-B2-band'][0:101].values
# rsf_MB2_value=df_base['M-B2-RSF'][0:101].values
#
# rsf_MB3 =df_base['M-B3-band'][0:101].values
# rsf_MB3_value=df_base['M-B3-RSF'][0:101].values
#
# rsf_MB4 =df_base['M-B4-band'][0:101].values
# rsf_MB4_value=df_base['M-B4-RSF'][0:101].values
#
# # glob获得路径下所有文件，可根据需要修改
# radcalnet_file_list = glob(str(radcalnet_filedir + '\\') + '*')
# with open(r"H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\315(20km-5)\BT_TOA1.csv", "w") as csvfile:
#     writer = csv.writer(csvfile)
#     writer.writerow(["filename", "F_B1", "F_B2", "F_B3", "F_B4", "M_B1", "M_B2", "M_3","M_B4"])
#     file_length = len(radcalnet_file_list)
#     for radcalnet in radcalnet_file_list:
#         file_length=file_length-1
#         fpath, fname = os.path.split(radcalnet)  # 分离文件名和路径
#         df_radcalnet=pd.read_excel(radcalnet)
#         TOA_radcalnet=df_radcalnet['12:00'].values
#         band_radcalnet=df_radcalnet['band'].values
#         f1 = interp1d(band_radcalnet[0:61], TOA_radcalnet[0:61])
#
#         y_TOA_FB1=f1(rsf_FB1)
#         s_FB1=y_TOA_FB1*rsf_FB1_value
#         fenzi_FB1=np.trapz(s_FB1)
#         fenmu_FB1=np.trapz(rsf_FB1_value)
#         result_FB1 = fenzi_FB1/fenmu_FB1
#
#         y_TOA_FB2 = f1(rsf_FB2)
#         result_FB2 = np.trapz(y_TOA_FB2 * rsf_FB2_value) / np.trapz(rsf_FB2_value)
#
#         y_TOA_FB3 = f1(rsf_FB3)
#         result_FB3 = np.trapz(y_TOA_FB3 * rsf_FB3_value) / np.trapz(rsf_FB3_value)
#
#         y_TOA_FB4 = f1(rsf_FB4)
#         result_FB4 = np.trapz(y_TOA_FB4 * rsf_FB4_value) / np.trapz(rsf_FB4_value)
#
#         y_TOA_MB1 = f1(rsf_MB1)
#         result_MB1 = np.trapz(y_TOA_MB1 * rsf_MB1_value) / np.trapz(rsf_MB1_value)
#
#         y_TOA_MB2 = f1(rsf_MB2)
#         result_MB2 = np.trapz(y_TOA_MB2 * rsf_MB2_value) / np.trapz(rsf_MB2_value)
#
#         y_TOA_MB3 = f1(rsf_MB3)
#         result_MB3 = np.trapz(y_TOA_MB3 * rsf_MB3_value) / np.trapz(rsf_MB3_value)
#
#         y_TOA_MB4 = f1(rsf_MB4)
#         result_MB4 = np.trapz(y_TOA_MB4 * rsf_MB4_value) / np.trapz(rsf_MB4_value)
#
#
#         result= [str(fname[7:11])+str(fname[12:15]), result_FB1, result_FB2,result_FB3,result_FB4,result_MB1,result_MB2,result_MB3,result_MB4]
#         #写入多行用writerows
#         writer.writerow(result)
#         print(fname+''+str(file_length))

input_file_TOA = r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\315(20km-5)\BT_TOA.xlsx'
# *****************************Excel文件数据读取*****************************
df_base_1= pd.read_excel(input_file_TOA,sheet_name="BT_TOA")  # From an Excel file
df_base=df_base_1[df_base_1['F_B1']<100]

fyband1=df_base['F_B1'].values
fyband2=df_base['F_B2'].values
fyband3=df_base['F_B3'].values
fyband4=df_base['F_B4'].values

modisband1=df_base['M_B1'].values
modisband2=df_base['M_B2'].values
modisband3=df_base['M_B3'].values
modisband4=df_base['M_B4'].values

s=modisband3/fyband1
SBAF_fyb1=np.mean(s)

SBAF_fyb2=np.mean(modisband4/fyband2)

SBAF_fyb3=np.mean(modisband1/fyband3)

SBAF_fyb4=np.mean(modisband2/fyband4)

print([SBAF_fyb1,SBAF_fyb2,SBAF_fyb3,SBAF_fyb4])

# *****************************FY3D*****************************


# band0=df_base['b'].values
# print(band0)
# band1=df_base['band1'].values
# f1 = interp1d(band1,df_base['real'])
# y1 = f1(band0)
# print('1111')
# df_base['bb']=y1
# print('2222')
# s=y1*df_base['f'].values
# fenzi=np.trapz(s)
# fenmu=np.trapz(df_base['f'].values)
# result_band1 = fenzi/fenmu
# coding=utf-8
import numpy as np
import pandas as pd
import datetime

from FY3D.Demofunction.JDay_calculate import time2mjd
from MODIS.Demofunction import timereolace

# **************************************
# fy3d和modis文件的数据过滤
# 首先计筛选std<0.013的数据
# 进行2q过滤（Assessment of Radiometric Degradation of FY -3A MERSI Reflective Solar Bands Using TOA Reflectance of Pseudoinvariant Calibration Sites）
# **************************************

input_file=r'H:\00data\MODIS\DCC\TOA\DCC_2019_modis-2-le0.8.xlsx'
# input_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\311(20km-4)\dh_dingbiao_modis20km-4-novz.xlsx'

# *****************************Excel文件数据读取*****************************
for fyband in ['MODIS_B1', 'MODIS_B2', 'MODIS_B3', 'MODIS_B4']:
    STD=fyband+str('_STD')

df_base_1 = pd.read_excel(input_file, sheet_name="DCC_2019_modis-2-le0.8",usecols=['MODIS_DateBase','MODIS_SZ','MODIS_SA','MODIS_VZ','MODIS_VA','MODIS_RA','MODIS_B1','MODIS_B1_STD'])  # From an Excel file
df_base_1.dropna(inplace = True)

# df_base=df_base_1[(df_base_1['MODIS_SZ']<60) & (df_base_1['MODIS_VZ']<40) & (df_base_1['MODIS_RA']>60) & (df_base_1['MOIS_B1_STD']<0.010) & (df_base_1['MODIS_B2_STD']<0.010) & (df_base_1['MODIS_B3_STD']<0.010) & (df_base_1['MODIS_B4_STD']<0.010)]
df_base=df_base_1[ df_base_1['MODIS_B1_STD']<0.05]

# for fyband in ['FY_B1','FY_B2','FY_B3','FY_B4'] :
# for fyband in ['MODIS_B1', 'MODIS_B2', 'MODIS_B3', 'MODIS_B4']:
# 将列表按每20个数据进行分割
fy_new=np.array([])
fy=df_base['MODIS_B1'].values
split_data = np.array_split(fy,len(fy)/20+1)
for data in split_data:
    filtered_data = np.zeros_like(data)
    for i in range(len(data)):
        local_mean = np.mean(data)  # 计算局部平均值
        local_std = np.std(data)  # 计算局部标准差
        # 如果该数据点偏离局部平均值超过2个局部标准差，则认为该数据点受到污染

        if abs(data[i] - local_mean) > 2 * local_std:
            filtered_data[i] = np.NAN  # 使用局部平均值替换该数据点
        else:
            filtered_data[i] = data[i]  # 如果该数据点没有受到污染，则不做处理
    fy_new = np.hstack((fy_new, filtered_data))
df_base['MODIS_B1']=fy_new
df_base.dropna(inplace = True)

with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
        df_base.to_excel(writer, sheet_name='MODIS_B1',index=False,header = True)
print('111')

datebase=df_base['MODIS_DateBase'].values
year_out=[]
month_out=[]
day_out=[]
for date in datebase:
    date_str=str(date)
    year=int(date_str[0:4])
    month=int(date_str[4:6])
    day=int(date_str[6:8])
    year_out.append(year)
    month_out.append(month)
    day_out.append(day)

df_base['year']=year_out
df_base['month']=month_out
df_base['day']=day_out

aver = df_base.groupby(['year', 'month','day']).mean()

df = aver.loc[:, ['MODIS_B1']]
# df = aver.loc[:, ['FY_B1', 'FY_B2','FY_B3','FY_B4']]
with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
    df.to_excel(writer, sheet_name="aver_day"+str('MODIS_B1'), index=True, header=True)
print('1111')
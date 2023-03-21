# coding=utf-8
import datetime

import numpy as np
import pandas as pd


# **************************************
# toa月均值计算
# **************************************


# input_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\317(10km-6)\dh_dingbiao_fy3d10km_6.xlsx'
# input_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\317(10km-6)\dh_dingbiao_modis10km_6.xlsx'
input_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\20km\dh_dingbiao_modisd20km_4-RA.xlsx'
# input_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\311(20km-4)\dh_dingbiao_modis20km-4-novz.xlsx'
output_fig=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\311(20km-4)\plot'+'\\'

# *****************************Excel文件数据读取*****************************
df_base = pd.read_excel(input_file, sheet_name="2q+stdlt0.010")  # From an Excel file
# datebase=df_base['FY_DateBase'].values
datebase=df_base['MODIS_DateBase'].values
year_out=[]
month_out=[]
for date in datebase:
    date_str=str(date)
    year=int(date_str[0:4])
    month=int(date_str[4:6])
    year_out.append(year)
    month_out.append(month)

df_base['year']=year_out
df_base['month']=month_out

aver = df_base.groupby(['year', 'month']).mean()

df = aver.loc[:, ['MODIS_B1', 'MODIS_B2','MODIS_B3','MODIS_B4']]
# df = aver.loc[:, ['FY_B1', 'FY_B2','FY_B3','FY_B4']]
with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
    df.to_excel(writer, sheet_name="aver0.010", index=True, header=True)
print('1111')
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

input_file=r'H:\00data\MODIS\DCC\TOA\0.8\DCC_2019_modis.xlsx'

# *****************************Excel文件数据读取*****************************
for band in ['MODIS_B1', 'MODIS_B2', 'MODIS_B3', 'MODIS_B4']:
    band_STD=band+str('_STD')

    df_base_1 = pd.read_excel(input_file, sheet_name="DCC_2019_modis-gt0.8",usecols=['MODIS_DateBase','MODIS_CNOTNAN','MODIS_SZ','MODIS_SA','MODIS_VZ','MODIS_VA','MODIS_RA',band,band_STD])  # From an Excel file
    df_base_1.dropna(inplace = True)
    df_base=df_base_1[ df_base_1['MODIS_CNOTNAN']>300]

    # with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
    #     df_base.to_excel(writer, sheet_name=band,index=False,header = True)
    print(band)

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

    aver_day = df_base.groupby(['year', 'month','day']).mean()
    df_day = aver_day.loc[:, ['MODIS_SZ','MODIS_SA','MODIS_VZ','MODIS_VA','MODIS_RA',band]]
    df_day_index=list(df_day.index)
    datetime=[]
    for y,m,d in df_day_index:
        date=str(y)+'{:0>2d}'.format(m)+'{:0>2d}'.format(d)
        datetime.append(int(date))
    df_day['MODIS_DateBase']=datetime
    # ss=str(df_day['year'])+str(df_day['month'])+str(df_day['day'])
    # 将列表按每20个数据进行分割
    MODIS_new=np.array([])
    modis=df_day[band].values
    split_data = np.array_split(modis,len(modis)/20+1)
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
        MODIS_new = np.hstack((MODIS_new, filtered_data))
    df_day[band]=MODIS_new
    df_day.dropna(inplace = True)
    aver_month = df_day.groupby(['year', 'month']).mean()
    df_month = aver_month.loc[:, [band]]
    with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
        df_day.to_excel(writer, sheet_name="aver_day_"+str(band), index=False, header=True)
    print(band+'成功')

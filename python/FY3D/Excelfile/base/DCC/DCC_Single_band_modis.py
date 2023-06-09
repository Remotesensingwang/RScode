# coding=utf-8
import numpy as np
import pandas as pd
import datetime


# **************************************
# MODIS文件DCC范围的数据过滤
# 首先按照band筛选有效值（count）的数据
# 进行2q过滤（Assessment of Radiometric Degradation of FY -3A MERSI Reflective Solar Bands Using TOA Reflectance of Pseudoinvariant Calibration Sites）
# **************************************

input_file=r'H:\00data\TOA\DCC\MODIS\407\base\DCC_modis-0.0.xlsx'
out=r'H:\00data\TOA\DCC\MODIS\407\base\DCC_MODIS-0.0-base.xlsx'
# *****************************Excel文件数据读取*****************************
value_count1=[300,50,300,300,1000,300,1000,30,10,300,200,200]
# value_count2=[]
input_file1=r'H:\00data\TOA\DCC\MODIS\407\data\base\dcc_base_modis_day.xlsx'
input_file2=r'H:\00data\TOA\DCC\MODIS\407\data\base\dcc_base_modis_month.xlsx'
for band in ['M_B1', 'M_B2', 'M_B3', 'M_B4','M_B5', 'M_B6', 'M_B7', 'M_B8', 'M_B17', 'M_B18','M_B19', 'M_B26']:
    # band_STD=band+str('_STD')
    count=band+str('_C')
    df_base_1 = pd.read_excel(input_file, sheet_name="base",usecols=['M_DateBase','M_SZ','M_SA','M_VZ','M_VA','M_RA','M_COUNT',count,band])  # From an Excel file
    df_base_1.dropna(inplace = True)
    if band == 'M_B2' : value_count=50
    elif band == 'M_B5' or band == 'M_B7' : value_count=1000
    elif band == 'M_B8':value_count = 30
    elif band == 'M_B17':value_count = 10
    elif band == 'M_B18':value_count = 300
    elif band == 'M_B19' or band == 'M_B26': value_count = 200
    else: value_count=300
    df_base = df_base_1[(df_base_1[count] > value_count)]
    # with pd.ExcelWriter(out, mode='a', engine='openpyxl') as writer:
    #     df_base_1.to_excel(writer, sheet_name=band,index=False,header = True)
    print(band)
    datebase=df_base['M_DateBase'].values
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
    df_day = aver_day.loc[:, ['M_SZ','M_SA','M_VZ','M_VA','M_RA',band]]
    df_day_index=list(df_day.index)
    datetime=[]
    for y,m,d in df_day_index:
        date=str(y)+'{:0>2d}'.format(m)+'{:0>2d}'.format(d)
        datetime.append(int(date))
    df_day['M_DateBase']=datetime
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
    # with pd.ExcelWriter(input_file1, mode='a', engine='openpyxl') as writer:
    #     df_day.to_excel(writer, sheet_name="aver_day_"+str(band), index=False, header=True)
    # with pd.ExcelWriter(input_file2, mode='a', engine='openpyxl') as writer:
    #     df_month.to_excel(writer, sheet_name="aver_month_"+str(band), index=True, header=True)
    print(band+'成功')
print('1111')
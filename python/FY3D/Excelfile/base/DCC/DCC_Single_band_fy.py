# coding=utf-8
import numpy as np
import pandas as pd

# *************************************
# fy3d的DCC数据过滤
# 只提取有效值大于300的值
#
# 进行2q过滤（Assessment of Radiometric Degradation of FY -3A MERSI Reflective Solar Bands Using TOA Reflectance of Pseudoinvariant Calibration Sites）
# **************************************

input_file=r'H:\00data\FY3D\DCC\TOA\0.8\DCC_2019_fy.xlsx'

# *****************************Excel文件数据读取*****************************
for fyband in ['FY_B1', 'FY_B2', 'FY_B3', 'FY_B4']:
    fyband_STD=fyband+str('_STD')

    df_base_1 = pd.read_excel(input_file, sheet_name="Sheet1",usecols=['FY_DateBase','FY_CNOTNAN','FY_SZ','FY_SA','FY_VZ','FY_VA','FY_RA',fyband,fyband_STD])  # From an Excel file
    df_base_1.dropna(inplace = True)
    df_base=df_base_1[ df_base_1['FY_CNOTNAN']>300]

    with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
        df_base.to_excel(writer, sheet_name=fyband,index=False,header = True)
    print(fyband)

    datebase=df_base['FY_DateBase'].values
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
    df_day = aver_day.loc[:, ['FY_SZ','FY_SA','FY_VZ','FY_VA','FY_RA',fyband]]
    df_day_index=list(df_day.index)
    # (2019,1,7)
    datetime=[]
    for y,m,d in df_day_index:
        date=str(y)+'{:0>2d}'.format(m)+'{:0>2d}'.format(d)
        datetime.append(int(date))
    df_day['FY_DateBase']=datetime

    # 将列表按每20个数据进行分割
    fy_new=np.array([])
    fy=df_day[fyband].values
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
    df_day[fyband]=fy_new
    df_day.dropna(inplace = True)
    aver_month = df_day.groupby(['year', 'month']).mean()
    df_month = aver_month.loc[:, [fyband]]
    with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
        df_day.to_excel(writer, sheet_name="aver_day_"+str(fyband), index=False, header=True)
    print(fyband+'成功')
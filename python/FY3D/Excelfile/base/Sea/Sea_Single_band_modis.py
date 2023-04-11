# coding=utf-8
import numpy as np
import pandas as pd

# **************************************
# MODIS文件Sea范围的数据过滤
# 只提取有效值（count）大于3000的值
# 进行2q过滤（Assessment of Radiometric Degradation of FY -3A MERSI Reflective Solar Bands Using TOA Reflectance of Pseudoinvariant Calibration Sites）
# **************************************

input_file=r'H:\00data\TOA\Sea\MODIS\base\TNP_modis_2019.xlsx'
out=r'H:\00data\TOA\Sea\MODIS\base\TNP_modis_2019-base.xlsx'
# *****************************Excel文件数据读取*****************************
input_file1=r'H:\00data\TOA\Sea\MODIS\data\base\sea_base_modis_day.xlsx'
input_file2=r'H:\00data\TOA\Sea\MODIS\data\base\sea_base_modis_month.xlsx'
for band in [ 'M_B1', 'M_B2', 'M_B3', 'M_B4', 'M_B6', 'M_B7', 'M_B8', 'M_B9', 'M_B10', 'M_B12','M_B13L', 'M_B13H', 'M_B15', 'M_B16', 'M_B17', 'M_B18','M_B19', 'M_B26']:
    # band_STD=band+str('_STD')
    count=band+str('_C')
    df_base_1 = pd.read_excel(input_file, sheet_name="base",usecols=['M_DateBase','M_SZ','M_SA','M_VZ','M_VA','M_RA','M_SCA','M_COUNT',count,band])  # From an Excel file
    df_base_1.dropna(inplace = True)
    df_base = df_base_1[(df_base_1[count] > 3000)]
    # with pd.ExcelWriter(out, mode='a', engine='openpyxl') as writer:
    #     df_base.to_excel(writer, sheet_name=band,index=False,header = True)
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
    df_day = aver_day.loc[:, ['M_SZ','M_SA','M_VZ','M_VA','M_RA','M_SCA',band]]
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